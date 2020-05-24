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
    
    func testTotalTouchCount() {
        var recordHolder = RecordHolder()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let laterInDay = Calendar.current.date(byAdding: .hour, value: 3, to: startOfDay)!
        
        XCTAssert(recordHolder.totalTouchCount == 0)
        
        recordHolder.add(dummyRecordWith(date: startOfDay))
        XCTAssert(recordHolder.totalTouchCount == 1)
        
        recordHolder.add(dummyRecordWith(date: laterInDay))
        XCTAssert(recordHolder.totalTouchCount == 2)
    }
    
    func testArrayAddition() {
        var recordHolder = RecordHolder()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let dummyOne = dummyRecordWith(date: startOfDay)
        
        let laterInDay = Calendar.current.date(byAdding: .hour, value: 2, to: startOfDay)!
        let dummyTwo = dummyRecordWith(date: laterInDay)
        
        XCTAssert(recordHolder.totalTouchCount == 0)
        let records = [dummyOne, dummyTwo]
        recordHolder.add(records)
        
        XCTAssert(recordHolder.totalTouchCount == 2)
    }
    
    func testRepeatArrayAddition() {
        var recordHolder = RecordHolder()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        // two of same date, this should be handled by this function
        let dummyOne = dummyRecordWith(date: startOfDay)
        let dummyTwo = dummyRecordWith(date: startOfDay)
        
        let laterInDay = Calendar.current.date(byAdding: .hour, value: 2, to: startOfDay)!
        let dummyThree = dummyRecordWith(date: laterInDay)
        
        XCTAssert(recordHolder.totalTouchCount == 0)
        let records = [dummyOne, dummyTwo, dummyThree]
        recordHolder.add(records)
        
        XCTAssert(recordHolder.totalTouchCount == 2)
    }
    
    func testRepeatAddition() {
        var recordHolder = RecordHolder()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let dummy = dummyRecordWith(date: startOfDay)
        
        XCTAssert(recordHolder.totalTouchCount == 0)
        recordHolder.add(dummy)
        
        XCTAssert(recordHolder.totalTouchCount == 1)
        recordHolder.add(dummy)
        
        XCTAssert(recordHolder.totalTouchCount == 1)
    }
    
    private func dummyRecordWith(date: Date) -> TouchRecord {
        return TouchRecord(deviceName: "test",
                           timestamp: date,
                           version: "123")
    }
}
