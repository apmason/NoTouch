//
//  RecordHolder.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public typealias Touch = Int

public enum LabelPosition {
    case top
    case middle
    case bottom
}

/// Holds information on how many touches occured in a given hour.
public struct HourlyData: Identifiable {
    public var id = UUID()
    
    /// The hour in question. 0 is 12 midnight, 1 is 1 a.m, etc.
    let index: Int
    
    /// Number of touches in the hour.
    var touches: Touch
    
    /// Returns an array with 24 elements, starting at midnight (`HourlyData.hour == 0`)
    public static func generate24Hours() -> [HourlyData] {
        var returnArray: [HourlyData] = []
        for i in 0..<24 {
            returnArray.append(HourlyData(index: i, touches: 0))
        }
        return returnArray
    }
    
    enum PartOfDay: String {
        case am = "AM"
        case pm = "PM"
    }

    var dateText: String {
        var partOfDay: PartOfDay = .am
        
        // 12 midnight
        var startHour: Int = 12
        
        for hour in 0..<24 {
            let start: Int = startHour
            let end: Int = start == 12 ? 1 : start + 1
            
            if index == hour {
                return "\(start) - \(end) \(partOfDay.rawValue)"
            }
            
            startHour = end
            
            // Prepare for the roll over next iteration.
            if startHour == 12 {
                partOfDay = .pm
            }
        }
        
        return ""
    }
}

public struct RecordHolder {
    
    /// Each item in the array represents one hour in a day.
    public var hourlyData: [HourlyData] = HourlyData.generate24Hours()
    
    private var touchRecords: Set<TouchRecord> = []
    
    private var topAxisValue: Touch = 0
    
    // TODO: Make sure topAxisValue changes when we add a record.
    public mutating func add(_ record: TouchRecord) {
        self.touchRecords.insert(record)
        updateAfterRecordAddition()
    }
    
    public mutating func add(_ records: [TouchRecord]) {
        let recordSet: Set<TouchRecord> = Set(records)
        self.touchRecords = self.touchRecords.union(recordSet)
        updateAfterRecordAddition()
    }
    
    public func axisValue(for position: LabelPosition) -> Touch {
        switch position {
        case .top:
            return self.topAxisValue
            
        case .middle:
            return (self.topAxisValue / 3) * 2
            
        case .bottom:
            return (self.topAxisValue / 3)
            
        }
    }
    
    public var totalTouchCount: Touch {
        return self.hourlyData.reduce(0, {
            $0 + $1.touches
        })
    }
    
    public func latestTouchRecordDate(withOrigin origin: TouchRecord.Origin) -> Date? {
        return self.touchRecords.latestTouchRecordDate(withOrigin: origin)
    }
    
    /// Only adds updates for the current date, which may change in the future.
    private mutating func updateAfterRecordAddition() {
        let todaysRecords = self.touchRecords.todaysRecords()
        self.hourlyData.updateTouchesPerHour(from: todaysRecords, on: Date())
        assert(self.hourlyData.count == 24)
        self.topAxisValue = self.hourlyData.topAxisValue
    }
}
