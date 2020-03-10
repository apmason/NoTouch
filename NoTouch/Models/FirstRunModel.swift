//
//  FirstRunModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

class FirstRunModel {
    private static let firstRunKey = "firstRun"
    
    static var firstRunCompleted: Bool {
        return UserDefaults.standard.bool(forKey: firstRunKey)
    }
    
    static func setFirstRunCompleted() {
        UserDefaults.standard.set(true, forKey: firstRunKey)
    }
}
