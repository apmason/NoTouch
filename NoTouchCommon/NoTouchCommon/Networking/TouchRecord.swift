//
//  TouchRecord.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

struct TouchRecord: Identifiable {
    let id = UUID()
    let deviceName: String
    let timestamp: Date
    let version: String
}

typealias Touch = Int

// Get all the TouchRecord's
// Find one's that are happening on this day (in the user's timezone.)
// Then break into hourly data points.
// We need the max across the daily data so we can set the Y axis top value.
// Always save to DB as UTC time. Convert from UTC to the user's local timezone.

extension Collection where Element == TouchRecord {
    
    /// Returns a filtered list that contains only the records that occured on a given day, in the local timezone.
    func todaysRecords() -> [TouchRecord] {
        return self.filter({
            $0.timestamp.isToday()
        })
    }
    
    /// Returns an array representing the number of touches that occur each hour of the day. The return array will be 24 elements in size. Index 0 represent 12am - 1am and so on.
    func getTouchesPerHour() -> [Touch] {
        var returnArray = [Touch](repeating: 0, count: 24)
        
        // get each hour of the day.
        self.forEach({
            let hour = Calendar.current.component(.hour, from: $0.timestamp)
            returnArray[hour] += 1
        })
        
        return returnArray
    }
}

extension Collection where Element == Touch {
    
    func topAxisValue() -> Touch {
        var maxValue = self.max() ?? 0
        while maxValue % 5 != 0 && maxValue % 10 != 0 {
            maxValue += 1
        }
        return maxValue
    }
}
