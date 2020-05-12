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

public struct RecordHolder {
    
    public var touchObservances: [Touch] = [Touch](repeating: 0, count: 24)
    
    private var touchRecords: [TouchRecord] = []
    
    private var topAxisValue: Touch = 0
    
    // TODO: Make sure topAxisValue changes when we add a record.
    public mutating func add(_ record: TouchRecord) {
        self.touchRecords.append(record)
        let todaysRecords = self.touchRecords.todaysRecords().getTouchesPerHour(forDay: Date())
        self.touchObservances = todaysRecords
        assert(self.touchObservances.count == 24)
        self.topAxisValue = self.touchObservances.topAxisValue
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
        return self.touchObservances.reduce(0, {
            $0 + $1
        })
    }
}
