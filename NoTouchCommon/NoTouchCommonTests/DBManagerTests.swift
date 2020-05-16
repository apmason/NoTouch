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
        XCTAssert(userSettings.recordHolder.touchObservances.count == 24)
        for touch in userSettings.recordHolder.touchObservances {
            XCTAssert(touch == 0)
        }
        
        let expectation = XCTestExpectation(description: "Fetch existing record")
        
        // We will automatically fetch the old records.
        let dbManager = DBManager(userSettings: userSettings, database: MockDatabase())
        dbManager.fetchExistingRecords { result in
            if case Result.failure = result {
                XCTFail("Fetching failed")
            } else {
                XCTAssert(userSettings.recordHolder.touchObservances.count == 24)
                for (index, touch) in userSettings.recordHolder.touchObservances.enumerated() {
                    if index == 0 {
                        XCTAssert(touch == 1)
                    } else {
                        XCTAssert(touch == 0)
                    }
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 4)
    }
    
    func testDatabaseRecordConversion() {
        let deviceName = "Alex's Mac"
        let timestamp = Date()
        let version = "123"
        let touchRecord = TouchRecord(deviceName: deviceName, timestamp: timestamp, version: version)
        
        let database = MockDatabase()
        let ckRecord = database.ckRecord(from: touchRecord)
        
        XCTAssert(ckRecord[NetworkingConstants.deviceNameKey] == deviceName)
        XCTAssert(ckRecord[NetworkingConstants.timestampKey] == timestamp as NSDate)
        XCTAssert(ckRecord[NetworkingConstants.versionKey] == version)
    }
}

extension DBManagerTests {
    
    class MockDatabase: Database {
        func saveTouchRecord(_ record: TouchRecord, completionHandler: @escaping (Result<Void, Error>) -> Void) {}
        
        /// Return one `TouchRecord` in the `completionHandler`
        func fetchRecords(for date: Date, completionHandler: @escaping (Result<[TouchRecord], Error>) -> Void) {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let record = TouchRecord(deviceName: "123", timestamp: startOfDay, version: "123")
            completionHandler(.success([record]))
        }
    }
}
