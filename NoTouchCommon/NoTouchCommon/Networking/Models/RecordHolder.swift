//
//  RecordHolder.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public struct RecordHolder {
    
    private var touchRecords: [TouchRecord] = []
    
    public var touchObservances: [Touch] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    public var topAxisValue: Touch = 0
    
    public init() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.touchObservances = [0, 0, 0, 0, 0, 0, 0, 4, 4, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                self.touchObservances = [1, 1, 1, 0, 0, 0, 0, 4, 4, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0]
//            }
//        }
    }
    
    public mutating func add(_ record: TouchRecord) {
        self.touchRecords.append(record)
        let todaysRecords = self.touchRecords.todaysRecords().getTouchesPerHour(forDay: Date())
        self.touchObservances = todaysRecords
        print("Touch observances set to: \(self.touchObservances)")
        assert(self.touchObservances.count == 24)
        self.topAxisValue = self.touchObservances.topAxisValue
    }
}
