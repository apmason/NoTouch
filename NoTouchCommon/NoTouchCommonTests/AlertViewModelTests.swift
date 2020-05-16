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

    func testInitialFetching() {
        let mockDB = MockDatabase()
        let userSettings = UserSettings()
        _ = AlertViewModel(userSettings: userSettings, database: mockDB)
        
        let expectation = XCTestExpectation(description: "Wait for initial async fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
}

extension AlertViewModelTests {
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
