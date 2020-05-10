//
//  RecordHolder.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public class RecordHolder: ObservableObject {
    
    private var touchRecords: [TouchRecord] = []
    
    @Published public var touchObservances: [Touch] = []
    
    @Published public var topAxisValue: Touch = 0
    
    public func addRecord(_ record: TouchRecord) {
        self.touchRecords.append(record)
        let todaysRecords = self.touchRecords.todaysRecords()
        self.touchObservances = todaysRecords.getTouchesPerHour(forDay: Date())
        assert(self.touchObservances.count == 24)
        self.topAxisValue = touchObservances.topAxisValue
    }
}
