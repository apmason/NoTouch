//
//  TouchDetectedModel.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/7/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

class TouchDetectedModel: AlertObserver {
    
    private var userSettings: UserSettings
    
    init(_ userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func startAlerting() {
        self.userSettings.isTouching = true
    }
    
    func stopAlerting() {
        self.userSettings.isTouching = false
    }
}
