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
    var retryManager: RetryManager { get }
    
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
    public let retryManager: RetryManager = CloudKitRetryManager()
    
    /// This contains records that were not sent because of network conditions, or records that failed to save and need to be retried.
    private let recordsToSend: [TouchRecord] = []
    
    init(userSettings: UserSettings, database: Database) {
        self.userSettings = userSettings
        self.database = database
    }
    
    public func fetchExistingRecords(completionHandler: ((Result<Void, Error>) -> Void)?) {
        // Fetch all existing records for today.
        database.fetchRecords(for: Date()) { [weak self] result in
            switch result {
            case .success(let records):
                // create function to add multiple records.
                DispatchQueue.main.async {
                    self?.userSettings.recordHolder.add(records)
                    completionHandler?(.success(()))
                }
                
            case .failure(let error):
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
        
        database.saveTouchRecord(touchRecord) { result in
            switch result {
            case .success:
                break // don't need to do anything
                
            case .failure(let error):
                break // TODO: Handle this error, what's the issue?
            }
        }
    }

    /**
     
     Things to find out:
     -
     - Is there any error handling that needs to be done for that? Refetching if it decides to only get so many records?
     
     Other TODOs:
     -
     - What if CloudKit isn't available? We'll need to present something to the user telling them so. Is there a callback that we use to monitor for that? How do you present an action sheet in SwiftUI?
     */
}
