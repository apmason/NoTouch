//
//  DBManagerTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/14/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import XCTest

@testable import NoTouchCommon
class DBManagerTests: XCTestCase {

    func testRecordFetch() {
        let userSettings = UserSettings()
        let mockDB = MockDatabase()
        
        // Make sure we can make the network call.
        userSettings.networkTracker.isNetworkAvailable = true
        userSettings.networkTracker.cloudKitAuthStatus = .available
        
        let manager = DBManager(userSettings: userSettings, database: mockDB)
        
        let expectation = XCTestExpectation(description: "Wait for initial async fetch")
        
        manager.fetchExistingRecords { _ in
            XCTAssert(userSettings.recordHolder.touchObservances.count == 24)
            for (index, touch) in userSettings.recordHolder.touchObservances.enumerated() {
                if index == 0 {
                    XCTAssert(touch == 1)
                } else {
                    XCTAssert(touch == 0)
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testDatabaseRecordConversion() {
        let deviceName = "Alex's Mac"
        let timestamp = Date()
        let version = "123"
        let touchRecord = TouchRecord(deviceName: deviceName, timestamp: timestamp, version: version)
        
        let database = MockDatabase()
        let zoneID = CKRecordZone.ID(zoneName: "test", ownerName: "test")
        let ckRecord = database.ckRecord(from: touchRecord, recordZoneID: zoneID)
        
        XCTAssert(ckRecord[NetworkingConstants.deviceNameKey] == deviceName)
        XCTAssert(ckRecord[NetworkingConstants.timestampKey] == timestamp as NSDate)
        XCTAssert(ckRecord[NetworkingConstants.versionKey] == version)
    }
}

extension DBManagerTests {
    
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
