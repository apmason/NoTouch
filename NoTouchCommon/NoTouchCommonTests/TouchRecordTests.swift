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
    
    func testLatestRecordSuccess() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let todayRecord = TouchRecord(deviceName: "123", timestamp: today, version: "123")
        let tomorrowRecord = TouchRecord(deviceName: "123", timestamp: tomorrow, version: "123")
        let pastRecord = TouchRecord(deviceName: "123", timestamp: past, version: "123")
        
        let records: [TouchRecord] = [todayRecord, tomorrowRecord, pastRecord]
        
        let latestDate = records.latestTouchRecordDate()
        XCTAssert(latestDate == tomorrow)
    }
    
    func testLatestRecordEmpty() {
        let records: [TouchRecord] = []
        
        let latestDate = records.latestTouchRecordDate()
        XCTAssertNil(latestDate)
    }
}
