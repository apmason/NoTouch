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
    
    /// Fetch any records after the latest record's date.
    func fetchLatestRecords(completionHandler: @escaping ((Result<Void, DatabaseError>) -> Void))
    
    /// Create a `TouchRecord` at the specified `date` and save it to the database.
    /// - Parameter date: The date to use for the `TouchRecord`.
    func createAndSaveTouchRecord(at date: Date)
}

extension DatabaseManager {
    
    public func newestDBRecordDate() -> Date? {
        return userSettings.recordHolder.latestTouchRecordDate(withOrigin: .database)
    }
}

public class DBManager: DatabaseManager {
    public var database: Database
    public let userSettings: UserSettings
    public let networkMonitor: NetworkMonitor = NetworkMonitor()
    
    /// This contains records that were not sent because of network conditions, or records that failed to save and need to be retried.
    private var recordsToSend: [TouchRecord] = []
    
    /// Tracks whether we should fetch the latest records when we come back online or receive iCloud authentication.
    private var shouldFetchLatest: Bool = false
    
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
        
        database.fetchRecords(sinceStartOf: Date()) { [weak self] result in
            switch result {
            case .success(let records):
                DispatchQueue.main.async {
                    self?.userSettings.recordHolder.add(records)
                    completionHandler?(.success(()))
                }
                
            case .failure(let error):
                print("Error fetching existing records: \(error.localizedDescription)")
                completionHandler?(.failure(error))
                
            }
        }
    }
    
    public func fetchLatestRecords(completionHandler: @escaping ((Result<Void, DatabaseError>) -> Void)) {
        guard userSettings.networkTracker.isNetworkAvailable && userSettings.networkTracker.cloudKitAuthStatus == .available else {
            self.shouldFetchLatest = true
            return
        }
        
        database.fetchLatestRecords { [weak self] result in
            switch result {
            case .success(let records):
                self?.shouldFetchLatest = false
                
                DispatchQueue.main.async {
                    self?.userSettings.recordHolder.add(records)
                    completionHandler(.success(()))
                }
                
            case .failure(let error):
                self?.shouldFetchLatest = true
                completionHandler(.failure(error))
                
            }
        }
    }
    
    public func createAndSaveTouchRecord(at date: Date) {
        let deviceName = DeviceData.deviceName
        let appVersion = DeviceData.appVersion
        
        let touchRecord = TouchRecord(deviceName: deviceName,
                                      timestamp: date,
                                      version: appVersion,
                                      origin: .local)
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
        if database.initialRecordsFetchState == .notAttempted
            && userSettings.networkTracker.isNetworkAvailable
            && userSettings.networkTracker.cloudKitAuthStatus == .available {
            self.fetchExistingRecords(completionHandler: nil)
        }
    }
    
    private func attemptLatestRecordFetch() {
        if shouldFetchLatest {
            self.fetchLatestRecords { _ in }
        }
    }
}

// MARK: - RetryManagerDelegate

extension DBManager: NetworkMonitorDelegate {
        
    public func networkStateDidChange(_ networkAvailable: Bool) {
        if networkAvailable {
            database.attemptCustomZoneCreation()
        }
        
        // Update on the main thread because this may trigger a UI update.
        DispatchQueue.main.async { [weak self] in
            self?.userSettings.networkTracker.isNetworkAvailable = networkAvailable
            self?.attemptCachedRecordsSave()
            self?.attemptInitialRecordFetch()
            self?.attemptLatestRecordFetch()
        }
    }
}

// MARK: - DatabaseDelegate

extension DBManager: DatabaseDelegate {
    
    public func databaseAuthDidChange(_ status: DatabaseAuthStatus) {
        // Update on the main thread because this may trigger a UI update.
        DispatchQueue.main.async { [weak self] in
            self?.userSettings.networkTracker.cloudKitAuthStatus = status
            self?.attemptCachedRecordsSave()
            self?.attemptInitialRecordFetch()
            self?.attemptLatestRecordFetch()
        }
    }
}
