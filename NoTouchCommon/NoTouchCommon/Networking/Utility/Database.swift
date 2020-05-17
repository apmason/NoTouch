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
    case unknown
    case available
    case signedOut
    case restricted
}

public enum RecordFetchState {
    case notAttempted
    case inProcess
    case success
    case failure
}

public protocol DatabaseDelegate: class {
    func databaseAuthDidChange(_ status: DatabaseAuthStatus)
}

public protocol Database: class {
    
    /// Save an individual `TouchRecord`.
    /// - Parameters:
    ///   - record: The record to save.
    ///   - completionHandler: The async callback that will be called upon completion of the saving operation. This function will try to handle all errors that it can internally, retrying the save if told to. If the `completionHandler` returns a value of `Result.failure(.fatalError)` that means that the save encountered an unrecoverable error and should not be attempted again with this specific record.
    func saveTouchRecord(_ record: TouchRecord, completionHandler: @escaping (Result<Void, DatabaseError>) -> Void)
    
    /// Save an array of `TouchRecord` structures.
    /// - Parameters:
    ///   - records: The records to save.
    ///   - completionHandler: The async callback that will be called upon completion of the saving operation. This function will try to handle all errors that it can internally, retrying the save if told to. If the `completionHandler` returns a value of `Result.failure(.fatalError)` that means that the save encountered an unrecoverable error and should not be attempted again with these records.
    func saveTouchRecords(_ records: [TouchRecord], completionHandler: @escaping (Result<Void, DatabaseError>) -> Void)
    
    /// Fetch all records that occured on a specific date in a user's timezone.
    /// - Parameters:
    ///   - date: The date to fetch records for.
    ///   - completionHandler: The result of the operation.
    func fetchRecords(for date: Date, completionHandler: @escaping (Result<[TouchRecord], DatabaseError>) -> Void)
    
    var initialRecordsFetchState: RecordFetchState { get set }
    
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
