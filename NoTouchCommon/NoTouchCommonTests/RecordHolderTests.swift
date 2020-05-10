//
//  RecordHolderTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest

@testable import NoTouchCommon
class RecordHolderTests: XCTestCase {

    func testRecordHolderAddition() throws {
        let recordHolder = RecordHolder()
        
        XCTAssert(recordHolder.touchObservances.isEmpty)
        
        let past = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        recordHolder.addRecord(dummyRecordWith(date: past))
        XCTAssert(recordHolder.touchObservances.isEmpty)
        
        let future = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        recordHolder.addRecord(dummyRecordWith(date: future))
        XCTAssert(recordHolder.touchObservances.isEmpty)
        
        /// This is the start of the day, so the 0 index of the `touchObservances` array.
        let startOfDay = Calendar.current.startOfDay(for: Date())
        recordHolder.addRecord(dummyRecordWith(date: startOfDay))
        XCTAssert(recordHolder.$touchObservances.wrappedValue.count == 1)
        for (index, touchCount) in recordHolder.touchObservances.enumerated() {
            if index == 0 {
                XCTAssert(touchCount == 1)
            } else {
                XCTAssert(touchCount == 0)
            }
        }
    }
    
    func testTopAxisValueChange() {
        let recordHolder = RecordHolder()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        XCTAssert(recordHolder.topAxisValue == 0)
        recordHolder.addRecord(dummyRecordWith(date: startOfDay))
        for (index, touchCount) in recordHolder.touchObservances.enumerated() {
            if index == 0 {
                XCTAssert(touchCount == 1)
            } else {
                XCTAssert(touchCount == 0)
            }
        }
    }
    
    private func dummyRecordWith(date: Date) -> TouchRecord {
        return TouchRecord(deviceName: "test",
                           timestamp: date,
                           version: "123")
    }
}
