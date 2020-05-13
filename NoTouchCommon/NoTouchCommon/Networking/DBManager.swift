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

public class DBManager {
    
    private var database = CloudKitDatabase()
    private let userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    internal func createTouchRecord() {
        let deviceName = DeviceData.deviceName
        let date = Date()
        let appVersion = DeviceData.appVersion
        
        let touchRecord = TouchRecord(deviceName: deviceName,
                                      timestamp: date,
                                      version: appVersion)
        self.userSettings.recordHolder.add(touchRecord)
        
        // create item.
        // send to DB
        let record = CKRecord(recordType: RecordType.touch.rawValue)
        record["deviceName"] = deviceName
        record["timestamp"] = date // TODO: what timezone is this in?
        record["version"] = appVersion
        
        database.saveItem(record) { record, error in
            if let error = error {
                print("Attempt to save item failed: \(error.localizedDescription)")
            } else {
             //   print("Success!")
            }
        }
    }
    
    internal func readTouchRecord() -> [TouchRecord] {
        return []
    }
    
    private func fetchChanges(in databaseScope: CKDatabase.Scope) {
        database.fetchChanges(in: databaseScope) {
            // done, reset data.
        }
    }
    
    // What we want is: make a batched call to get records that occured on today (using a predicate).
    // we then store this data in the `userSettings.recordHolder`. Write tests for that. We can test the DBManager class. We will pass in a dummy `UserSettings` object. We will fetch records. We should pass in the DB stub that we want. (CloudKitDatabase should be a protocol, we can make a stub that performs the actions that we want (returning an array of TouchRecords)).
    
    /**
     
     Things to find out:
     -
     - What is the API to use to call into CloudKit with a predicate? <-- Doing this NOW.
     "When using such an operator, it is recommended that you use a cursor to batch the results into smaller groups for processing." - https://developer.apple.com/documentation/cloudkit/ckquery
     - Is there any error handling that needs to be done for that? Refetching if it decides to only get so many records?
     - Are there performance implications for storing all the records individually? I can't imagine that on the client side it will take up that much space.
     
     Other TODOs:
     -
     - What if CloudKit isn't available? We'll need to present something to the user telling them so. Is there a callback that we use to monitor for that? How do you present an action sheet in SwiftUI?
     */
}
