//
//  TouchRecord.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

public struct TouchRecord: Identifiable {
    public enum Origin {
        case database
        case local
    }
    
    public let id = UUID()
    let deviceName: String
    let timestamp: Date
    let version: String
    let origin: Origin
    
    public init(deviceName: String, timestamp: Date, version: String, origin: Origin) {
        self.deviceName = deviceName
        self.timestamp = timestamp
        self.version = version
        self.origin = origin
    }
}

extension TouchRecord: Equatable, Hashable {
    public static func == (lhs: TouchRecord, rhs: TouchRecord) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
    
    /// Only compare timestamps.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
}
