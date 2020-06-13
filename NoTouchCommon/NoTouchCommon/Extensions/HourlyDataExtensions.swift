//
//  HourlyDataExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/13/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

extension Array where Element == HourlyData {
    
    /// Based on the highest value in the collection, this value is the next highest `Touch` value that is divisible by 3, or the highest value itself if it is already divisible by 3.
    var topAxisValue: Touch {
        let touchArray: [Touch] = self.map({ $0.touches })
        
        var maxValue = touchArray.max() ?? 0
        while maxValue % 3 != 0 {
            maxValue += 1
        }
        return maxValue
    }
    
    /// Loops through the array of `touchRecord`s and increments the touch count for the corresponding hour that the event occured on.
    mutating func updateTouchesPerHour(from touchRecords: [TouchRecord], on date: Date) {
        self.clearTouches()
        
        for record in touchRecords {
            let hour = Calendar.current.component(.hour, from: record.timestamp)
            
            if Calendar.current.isDate(record.timestamp, inSameDayAs: date) {
                guard let index = self.firstIndex(where: { $0.hour == hour }) else {
                    assertionFailure("This shouldn't happen")
                    continue
                }
                
                self[index].touches += 1
            }
        }
    }
    
    /// Sets all of the `touches` values for elements in the collection to zero.
    mutating func clearTouches() {
        for i in 0..<self.count {
            self[i].touches = 0
        }
    }
}
