//
//  NoTouchCommonTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest
@testable import NoTouchCommon

class NoTouchCommonTests: XCTestCase {

    func testStringToDate() {
        let orig = Date(timeIntervalSince1970: 1588719436.0)
        let testDate = Date.dbStringToDate("2020-05-05T22:57:16 GMT",
                                         in: TimeZone(abbreviation: "EDT")!)!
        
        XCTAssert(orig == testDate)
    }
    
    func testDateToString() {
        let orig = Date(timeIntervalSince1970: 1588719436.0)
        let dateString = Date.dateToDBString(orig, in: TimeZone(abbreviation: "EDT")!)
        XCTAssert(dateString == "2020-05-05T18:57:16 EDT")
    }
    
    func testTodaysRecords() {
        let todayRecord = dummyRecordWith(date: Date())
        
        let oldDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        let oldRecord = dummyRecordWith(date: oldDate)
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        let futureRecord = dummyRecordWith(date: futureDate)
        
        let records: [TouchRecord] = [todayRecord, oldRecord, futureRecord]
        
        XCTAssert(records.todaysRecords().count == 1)
    }
    
    func testTouchesPerHour() {
        let today = Date()
        let start = Calendar.current.startOfDay(for: today)
        
        let hourValue = 8
        // This will be 8AM
        let secondDate = Calendar.current.date(byAdding: .hour, value: hourValue, to: start)!
        
        let records: [TouchRecord] = [
            dummyRecordWith(date: start),
            dummyRecordWith(date: secondDate)
        ]
        
        let touches = records.getTouchesPerHour(forDay: today)
        
        XCTAssert(touches.count == 24)
        
        for i in 0..<touches.count {
            if i == 0 {
                XCTAssert(touches[i] == 1)
            } else if i == hourValue {
                XCTAssert(touches[i] == 1)
            } else {
                XCTAssert(touches[i] == 0)
            }
        }
    }
    
    func testToucherPerHourFailure() {
        let today = Date()
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: today)!
        let futureRecords: [TouchRecord] = [
            dummyRecordWith(date: futureDate),
            dummyRecordWith(date: futureDate)
        ]
        
        let futureHours = futureRecords.getTouchesPerHour(forDay: today)
        XCTAssert(futureHours.count == 24)
        for hour in futureHours {
            XCTAssert(hour == 0)
        }
        
        let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let pastRecords: [TouchRecord] = [
            dummyRecordWith(date: pastDate),
            dummyRecordWith(date: pastDate)
        ]
        let pastHours = pastRecords.getTouchesPerHour(forDay: today)
        XCTAssert(futureHours.count == 24)
        for hour in pastHours {
            XCTAssert(hour == 0)
        }
    }
    
    func testTodaysTouchesPerHours() {
        let beginningOfDay = Calendar.current.startOfDay(for: Date())
        let todayRecord = dummyRecordWith(date: beginningOfDay)
        
        let oldDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        let oldRecord = dummyRecordWith(date: oldDate)
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        let futureRecord = dummyRecordWith(date: futureDate)
        
        let records: [TouchRecord] = [todayRecord, oldRecord, futureRecord]
        let todaysRecords = records.todaysRecords()
        XCTAssert(todaysRecords.count == 1)
        
        let touches = todaysRecords.getTouchesPerHour(forDay: Date())
        
        XCTAssert(touches.count == 24)
        
        for i in 0..<touches.count {
            if i == 0 {
                XCTAssert(touches[i] == 1)
            } else {
                XCTAssert(touches[i] == 0)
            }
        }
    }
    
    private func dummyRecordWith(date: Date) -> TouchRecord {
        return TouchRecord(deviceName: "test",
                           timestamp: date,
                           version: "123",
                           origin: .database)
    }
}
