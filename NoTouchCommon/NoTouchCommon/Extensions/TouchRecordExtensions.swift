//
//  TouchRecordExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

extension Collection where Element == TouchRecord {
    
    /// Returns a filtered list that contains only the records that occured today day, in the local timezone.
    func todaysRecords() -> [TouchRecord] {
        return self.filter({
            $0.timestamp.isToday()
        })
    }
    
    func latestTouchRecordDate(withOrigin origin: TouchRecord.Origin) -> Date? {
        let filteredArray = self.filter({ $0.origin == origin })
        return filteredArray.max(by: {
            $0.timestamp < $1.timestamp
        })?.timestamp
    }
}
