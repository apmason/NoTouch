//
//  AlertViewModelTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/14/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import XCTest

@testable import NoTouchCommon
class AlertViewModelTests: XCTestCase {


}

extension AlertViewModelTests {
    class MockDatabase: Database {
        
        func fetchLatestRecords(completionHandler: ((Result<[TouchRecord], DatabaseError>) -> Void)?) {}
        
        func attemptCustomZoneCreation() {}
        
        var initialRecordsFetchState: RecordFetchState = .notAttempted
        
        var delegate: DatabaseDelegate?
        
        func saveTouchRecord(_ record: TouchRecord, completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {}
        
        func saveTouchRecords(_ records: [TouchRecord], completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {}
        
        /// Return one `TouchRecord` in the `completionHandler`
        func fetchRecords(sinceStartOf date: Date, completionHandler: @escaping (Result<[TouchRecord], DatabaseError>) -> Void) {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let record = TouchRecord(deviceName: "123", timestamp: startOfDay, version: "123")
            completionHandler(.success([record]))
        }
    }
}
