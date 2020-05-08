//
//  TouchRecordExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

extension Collection where Element == TouchRecord {
    
    /// Returns a filtered list that contains only the records that occured on a given day, in the local timezone.
    func todaysRecords() -> [TouchRecord] {
        return self.filter({
            $0.timestamp.isToday()
        })
    }
    
    /// Returns an array representing the number of touches that occur each hour of the day. The return array will be 24 elements in size. Index 0 represent 12am - 1am and so on.
    func getTouchesPerHour(forDay date: Date) throws -> [Touch] {
        var returnArray = [Touch](repeating: 0, count: 24)
        
        for record in self {
            let hour = Calendar.current.component(.hour, from: record.timestamp)
            
            if !Calendar.current.isDate(record.timestamp, inSameDayAs: date) {
                throw NoTouchError.improperDatesUsed
            }
            
            returnArray[hour] += 1
        }
        
        return returnArray
    }
}
