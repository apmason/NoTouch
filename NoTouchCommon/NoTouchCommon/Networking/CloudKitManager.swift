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

protocol DatabaseManager {
    func createTouchRecord()
    func readTouchRecord() -> [TouchRecord]
}

// Maybe this class will conform to a certain type of protocol? Maybe not?
public class CloudKitManager: DatabaseManager, ObservableObject {
    
    private var database = CloudKitDatabase()
    
    var touchRecords: [TouchRecord] = [] {
        didSet {
            print("did set!")
            self.touchObservances = self.touchRecords.getTouchesPerHour()
        }
    }
    
    @Published var touchObservances: [Touch] = []
    
    func createTouchRecord() {
        let deviceName = DeviceData.deviceName
        let date = Date()
        let appVersion = DeviceData.appVersion
        
        let touchRecord = TouchRecord(deviceName: deviceName,
                                      timestamp: date,
                                      version: appVersion)
        self.touchRecords.append(touchRecord)
        
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
