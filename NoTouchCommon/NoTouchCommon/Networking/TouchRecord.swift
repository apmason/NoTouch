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
    public let id = UUID()
    let deviceName: String
    let timestamp: Date
    let version: String
    
    public init(deviceName: String, timestamp: Date, version: String) {
        self.deviceName = deviceName
        self.timestamp = timestamp
        self.version = version
    }
}
