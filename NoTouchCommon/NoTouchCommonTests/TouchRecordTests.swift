//
//  TouchRecordTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest

@testable import NoTouchCommon
class TouchRecordTests: XCTestCase {

    func testTouchRecordEquatableSuccess() {
        let date = Date()
        let recordOne = TouchRecord(deviceName: "123", timestamp: date, version: "123")
        let recordTwo = TouchRecord(deviceName: "123", timestamp: date, version: "123")
        
        XCTAssert(recordOne == recordTwo)
    }
    
    func testTouchRecordEquatableFailure() {
        let firstDate = Date()
        let secondDate = Calendar.current.date(byAdding: .hour, value: 1, to: firstDate)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: firstDate, version: "123")
        let recordTwo = TouchRecord(deviceName: "123", timestamp: secondDate, version: "123")
        
        XCTAssert(recordOne != recordTwo)
    }
    
    func testTouchRecordSetCreation() {
        let firstDate = Date()
        let secondDate = Calendar.current.date(byAdding: .hour, value: 1, to: firstDate)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: firstDate, version: "123")
        let recordTwo = TouchRecord(deviceName: "123", timestamp: secondDate, version: "123")
        
        var recordSet: Set<TouchRecord> = []
        recordSet.insert(recordOne)
        recordSet.insert(recordTwo)
        
        XCTAssert(recordSet.count == 2)
    }
    
    func testTouchRecordSetDuplicate() {
        let dateString = Date.dateToDBString(Date(), in: .current)
        let dbDate = Date.dbStringToDate(dateString, in: .current)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: dbDate, version: "123")
        let recordTwo = TouchRecord(deviceName: "123", timestamp: dbDate, version: "123")
        
        var recordSet: Set<TouchRecord> = []
        recordSet.insert(recordOne)
        recordSet.insert(recordTwo)
        
        XCTAssert(recordSet.count == 1)
    }
}
