//
//  TouchRecord.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

struct TouchRecord {
    let deviceName: String
    let touchTime: Date
    let version: String
    let id: UUID = UUID()
}

extension TouchRecord {
    
    func asCKRecord() {
        let recordID = CKRecord(recordType: NetworkingConstants.touchRecordType)
    }
}
