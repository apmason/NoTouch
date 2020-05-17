//
//  CloudKitManager.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI
import CloudKit
import Foundation

public protocol DatabaseManager {
    var database: Database { get }
    var userSettings: UserSettings { get }
    var networkMonitor: NetworkMonitor { get }
    
    /// From the database fetch all records that occured on the current date in the user's timezone.
    /// - Parameter completionHandler: The result of the fetching operation. Items will be added to the current cache and displayed to the user automatically, this completion will return success or failure of the operation in general.
    func fetchExistingRecords(completionHandler: ((Result<Void, Error>) -> Void)?)
    
    /// Create a `TouchRecord` at the specified `date` and save it to the database.
    /// - Parameter date: The date to use for the `TouchRecord`.
    func createAndSaveTouchRecord(at date: Date)
}

public class DBManager: DatabaseManager {
    public var database: Database
    public let userSettings: UserSettings
    public let networkMonitor: NetworkMonitor = NetworkMonitor()
    
    /// This contains records that were not sent because of network conditions, or records that failed to save and need to be retried.
    private var recordsToSend: [TouchRecord] = []
    
    init(userSettings: UserSettings, database: Database) {
        self.userSettings = userSettings
        self.database = database
        
        self.networkMonitor.delegate = self
        self.database.delegate = self
    }
    
    public func fetchExistingRecords(completionHandler: ((Result<Void, Error>) -> Void)?) {
        guard userSettings.networkTracker.isNetworkAvailable && userSettings.networkTracker.cloudKitAuthStatus == .available else {
            return
        }
        
        database.fetchRecords(for: Date()) { [weak self] result in
            switch result {
            case .success(let records):
                DispatchQueue.main.async {
                    self?.userSettings.recordHolder.add(records)
                    completionHandler?(.success(()))
                }
                
            case .failure(let error):
                // TODO: Tell the user we're having networking issues (if the error is a networking error.)
                print(error.localizedDescription)
                completionHandler?(.failure(error))
                
            }
        }
    }
    
    public func createAndSaveTouchRecord(at date: Date) {
        let deviceName = DeviceData.deviceName
        let appVersion = DeviceData.appVersion
        
        let touchRecord = TouchRecord(deviceName: deviceName,
                                      timestamp: date,
                                      version: appVersion)
        self.userSettings.recordHolder.add(touchRecord) // Add to visible UI immediately.
        
        // Only attempt a save when the network is up and we are able to use CloudKit
        guard userSettings.networkTracker.isNetworkAvailable && userSettings.networkTracker.cloudKitAuthStatus == .available else {
            recordsToSend.append(touchRecord) // Cache the record for when we are able to send again.
            return
        }
        
        database.saveTouchRecord(touchRecord) { [weak self] result in
            switch result {
            case .success:
                break // don't need to do anything
                
            case .failure(let error):
                // The save failed, so cache this record to be uploaded when the issue is (hopefully) fixed in the future.
                switch error {
                case .fatalError: // something went horribly wrong, so just banish this record to the shadow realm.
                    break
                    
                default: // something went wrong, but try to retry in the future.
                    self?.recordsToSend.append(touchRecord)
                    
                }
            }
        }
    }
}

// MARK: - Handle Network Availability and Database Authorization

extension DBManager {
    
    /// If the network is up and we are signed in to CloudKit then send the saved records.
    private func attemptCachedRecordsSave() {
        // Attempt cached records save only if the network is up and the user is signed in to CloudKit.
        if !recordsToSend.isEmpty && userSettings.networkTracker.isNetworkAvailable && userSettings.networkTracker.cloudKitAuthStatus == .available {
            // To avoid a race condition copy the current items in the array. This avoids issues where the async task takes some time and more items are added in the meantime.
            let records = self.recordsToSend
            database.saveTouchRecords(records) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success:
                    let savedSet = Set(records)
                    let recordsToSendSet = Set(self.recordsToSend)
                    let remaining = recordsToSendSet.subtracting(savedSet)
                    self.recordsToSend = Array(remaining)
                    
                case .failure(let dbError):
                    switch dbError {
                    case .fatalError:
                        self.recordsToSend.removeAll() // If we hit a non-recoverable error dump everything.
                        
                    default:
                        break
                        
                    }
                }
            }
        }
    }
    
    /// If the network is up and we are signed in to CloudKit attempt to fetch the day's touch data from the server.
    private func attemptInitialRecordFetch() {
        if !database.hasCompletedInitialFetch && userSettings.networkTracker.isNetworkAvailable && userSettings.networkTracker.cloudKitAuthStatus == .available {
            self.fetchExistingRecords(completionHandler: nil)
        }
    }
}

// MARK: - RetryManagerDelegate

extension DBManager: NetworkMonitorDelegate {
        
    public func networkStateDidChange(_ networkAvailable: Bool) {
        // Update on the main thread because this may trigger a UI update.
        DispatchQueue.main.async { [weak self] in
            self?.userSettings.networkTracker.isNetworkAvailable = networkAvailable
        }
        
        attemptCachedRecordsSave()
        attemptInitialRecordFetch()
    }
}

// MARK: - DatabaseDelegate

extension DBManager: DatabaseDelegate {
    
    public func databaseAuthDidChange(_ status: DatabaseAuthStatus) {
        // Update on the main thread because this may trigger a UI update.
        DispatchQueue.main.async { [weak self] in
            self?.userSettings.networkTracker.cloudKitAuthStatus = status
        }
        
        attemptCachedRecordsSave()
        attemptInitialRecordFetch()
    }
}
