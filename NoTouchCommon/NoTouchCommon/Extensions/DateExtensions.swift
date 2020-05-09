//
//  DateExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/6/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
    
    static func dbStringToDate(_ dateString: String, in timeZone: TimeZone) -> Date? {
        dateFormatter.dateFormat = NetworkingConstants.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = timeZone
        return dateFormatter.date(from: dateString)
    }
    
    static func dateToDBString(_ date: Date, in timeZone: TimeZone) -> String {
        dateFormatter.dateFormat = NetworkingConstants.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: date)
    }
    
    /// Determines if a date occurs on today.
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
}
