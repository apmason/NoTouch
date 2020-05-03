//
//  CloudKitManager.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

protocol DatabaseManager {
    func createTouchRecord()
    func readTouchRecord() -> [TouchRecord]
}

// Maybe this class will conform to a certain type of protocol? Maybe not?
public class CloudKitManager: DatabaseManager {
    
    private var database = CloudKitDatabase()
    
    func createTouchRecord() {
        // create item.
        // send to DB
        let record = CKRecord(recordType: RecordType.touch.rawValue)
        record["deviceName"] = DeviceData.deviceName
        record["timestamp"] = Date()
        record["version"] = DeviceData.appVersion
        
        database.saveItem(record) { record, error in
            if let error = error {
                print("Attempt to save item failed: \(error.localizedDescription)")
            } else {
                print("Success!")
            }
        }
    }
    
    func readTouchRecord() -> [TouchRecord] {
        return []
    }
    
    public func fetchChanges(in databaseScope: CKDatabase.Scope) {
        database.fetchChanges(in: databaseScope) {
            // done, reset data.
        }
    }
    
    public init() {
        
    }
}
