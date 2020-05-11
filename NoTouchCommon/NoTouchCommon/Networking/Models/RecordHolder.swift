//
//  RecordHolder.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public typealias Touch = Int

public struct RecordHolder {
    
    private var touchRecords: [TouchRecord] = []
    
    public var touchObservances: [Touch] = [Touch](repeating: 0, count: 24)
    
    public var topAxisValue: Touch = 0
    
    public mutating func add(_ record: TouchRecord) {
        self.touchRecords.append(record)
        let todaysRecords = self.touchRecords.todaysRecords().getTouchesPerHour(forDay: Date())
        self.touchObservances = todaysRecords
        assert(self.touchObservances.count == 24)
        self.topAxisValue = self.touchObservances.topAxisValue
    }
}
