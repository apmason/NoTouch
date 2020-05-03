//
//  DatabaseWriter.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

protocol DatabaseWriter {
    
}

enum RecordType: String {
    case touch = "Touch"
}

class CloudKitWriter: DatabaseWriter {
    
    func createTouchRecord(touchRecord: TouchRecord) {
        let record = CKRecord(recordType: RecordType.touch.rawValue)
        record["devicename"] = touchRecord.deviceName
        record["timestamp"] = touchRecord.timestamp
        record["version"] = touchRecord.version
    }
}
