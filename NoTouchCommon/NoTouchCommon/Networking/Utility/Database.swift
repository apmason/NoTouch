//
//  Database.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

public enum DatabaseAuthStatus {
    case available
    case signedOut
    case restricted
}

public protocol DatabaseDelegate: class {
    func databaseAuthDidChange(_ status: DatabaseAuthStatus)
}

public protocol Database: class {
    func saveTouchRecord(_ record: TouchRecord, completionHandler: @escaping (Result<Void, DatabaseError>) -> Void)
    func saveTouchRecords(_ records: [TouchRecord], completionHandler: @escaping (Result<Void, DatabaseError>) -> Void)
    func fetchRecords(for date: Date, completionHandler: @escaping (Result<[TouchRecord], Error>) -> Void)
    var hasCompletedInitialFetch: Bool { get set }
    var delegate: DatabaseDelegate? { get set }
}

extension Database {
    
    func ckRecord(from touchRecord: TouchRecord) -> CKRecord {
        let ckRecord = CKRecord(recordType: RecordType.touch.rawValue)
        ckRecord["deviceName"] = touchRecord.deviceName
        ckRecord["timestamp"] = touchRecord.timestamp as NSDate
        ckRecord["version"] = touchRecord.version
        return ckRecord
    }
}
