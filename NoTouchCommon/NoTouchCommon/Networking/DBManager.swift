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

public protocol DBManagerDelegate: class {
    func add(_ record: TouchRecord)
}

// Maybe this class will conform to a certain type of protocol? Maybe not?
public class DBManager {
    
    //let recordHolder: RecordHolder
    
    private var database = CloudKitDatabase()
    
    //weak var delegate: DBManagerDelegate?
    
//    init(delegate: DBManagerDelegate) {
//        self.delegate = delegate
//    }
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
}
