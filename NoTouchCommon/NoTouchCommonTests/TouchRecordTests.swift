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
        let recordOne = TouchRecord(deviceName: "123", timestamp: date, version: "123", origin: .local)
        let recordTwo = TouchRecord(deviceName: "123", timestamp: date, version: "123", origin: .local)
        
        XCTAssert(recordOne == recordTwo)
    }
    
    func testTouchRecordEquatableFailure() {
        let firstDate = Date()
        let secondDate = Calendar.current.date(byAdding: .hour, value: 1, to: firstDate)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: firstDate, version: "123", origin: .local)
        let recordTwo = TouchRecord(deviceName: "123", timestamp: secondDate, version: "123", origin: .local)
        
        XCTAssert(recordOne != recordTwo)
    }
    
    func testTouchRecordSetCreation() {
        let firstDate = Date()
        let secondDate = Calendar.current.date(byAdding: .hour, value: 1, to: firstDate)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: firstDate, version: "123", origin: .local)
        let recordTwo = TouchRecord(deviceName: "123", timestamp: secondDate, version: "123", origin: .local)
        
        var recordSet: Set<TouchRecord> = []
        recordSet.insert(recordOne)
        recordSet.insert(recordTwo)
        
        XCTAssert(recordSet.count == 2)
    }
    
    func testTouchRecordSetDuplicate() {
        let dateString = Date.dateToDBString(Date(), in: .current)
        let dbDate = Date.dbStringToDate(dateString, in: .current)!
        
        let recordOne = TouchRecord(deviceName: "123", timestamp: dbDate, version: "123", origin: .local)
        let recordTwo = TouchRecord(deviceName: "123", timestamp: dbDate, version: "123", origin: .local)
        
        var recordSet: Set<TouchRecord> = []
        recordSet.insert(recordOne)
        recordSet.insert(recordTwo)
        
        XCTAssert(recordSet.count == 1)
    }
    
    func testNewestLocalRecordDate() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let todayRecord = TouchRecord(deviceName: "123", timestamp: today, version: "123", origin: .local)
        let tomorrowRecord = TouchRecord(deviceName: "123", timestamp: tomorrow, version: "123", origin: .local)
        let pastRecord = TouchRecord(deviceName: "123", timestamp: past, version: "123", origin: .local)
        
        let records: [TouchRecord] = [todayRecord, tomorrowRecord, pastRecord]
        
        let latestDate = records.latestTouchRecordDate(withOrigin: .local)
        XCTAssert(latestDate == tomorrow)
    }
    
    func testNewestDBRecordDate() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let todayRecord = TouchRecord(deviceName: "123", timestamp: today, version: "123", origin: .database)
        let tomorrowRecord = TouchRecord(deviceName: "123", timestamp: tomorrow, version: "123", origin: .database)
        let pastRecord = TouchRecord(deviceName: "123", timestamp: past, version: "123", origin: .database)
        
        let records: [TouchRecord] = [todayRecord, tomorrowRecord, pastRecord]
        
        let latestDate = records.latestTouchRecordDate(withOrigin: .database)
        XCTAssert(latestDate == tomorrow)
    }
    
    func testLatestRecordWithMixedDatabase() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let todayRecord = TouchRecord(deviceName: "123", timestamp: today, version: "123", origin: .local)
        let tomorrowRecord = TouchRecord(deviceName: "123", timestamp: tomorrow, version: "123", origin: .database)
        let pastRecord = TouchRecord(deviceName: "123", timestamp: past, version: "123", origin: .local)
        
        let records: [TouchRecord] = [todayRecord, tomorrowRecord, pastRecord]
        
        let latestDate = records.latestTouchRecordDate(withOrigin: .local)
        XCTAssert(latestDate == today)
    }
    
    func testLatestRecordEmpty() {
        let records: [TouchRecord] = []
        
        let latestDate = records.latestTouchRecordDate(withOrigin: .database)
        XCTAssertNil(latestDate)
    }
}
