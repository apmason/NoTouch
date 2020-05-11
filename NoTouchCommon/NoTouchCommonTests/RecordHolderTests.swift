//
//  RecordHolderTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI
import XCTest

@testable import NoTouchCommon
class RecordHolderTests: XCTestCase {

    func testRecordHolderAddition() throws {
        var recordHolder = RecordHolder()
        
        XCTAssert(recordHolder.touchObservances.count == 24)
        for touchCount in recordHolder.touchObservances {
            XCTAssert(touchCount == 0)
        }
        
        // Days in the past shouldn't be added.
        let past = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        recordHolder.add(dummyRecordWith(date: past))
        
        // Count should be 24 but all values are 0.
        XCTAssert(recordHolder.touchObservances.count == 24)
        for touchCount in recordHolder.touchObservances {
            XCTAssert(touchCount == 0)
        }
        
        
        // Days in the future shouldn't be added.
        let future = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        recordHolder.add(dummyRecordWith(date: future))
        
        // Count should be 24 but all values are 0.
        XCTAssert(recordHolder.touchObservances.count == 24)
        for touchCount in recordHolder.touchObservances {
            XCTAssert(touchCount == 0)
        }
        
        // This is the current day so we should have 24 entries, all being zero except for index 0 (12:01 on the current day).
        let startOfDay = Calendar.current.startOfDay(for: Date())
        recordHolder.add(dummyRecordWith(date: startOfDay))
        print("Seeing touch observance as: \(recordHolder.touchObservances)")
        XCTAssert(recordHolder.touchObservances.count == 24)
        
        for (index, touchCount) in recordHolder.touchObservances.enumerated() {
            if index == 0 {
                XCTAssert(touchCount == 1)
            } else {
                XCTAssert(touchCount == 0)
            }
        }
    }
    
    func testTopAxisValueChange() {
        var recordHolder = RecordHolder()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        XCTAssert(recordHolder.axisValue(for: .top) == 0)
        
        recordHolder.add(dummyRecordWith(date: startOfDay))
        XCTAssert(recordHolder.axisValue(for: .top) == 3)
    }
    
    private func dummyRecordWith(date: Date) -> TouchRecord {
        return TouchRecord(deviceName: "test",
                           timestamp: date,
                           version: "123")
    }
}
