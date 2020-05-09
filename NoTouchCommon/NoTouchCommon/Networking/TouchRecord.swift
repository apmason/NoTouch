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