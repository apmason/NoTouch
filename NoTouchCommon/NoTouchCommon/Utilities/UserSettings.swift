//
//  UserSettings.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/18/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public class UserSettings: ObservableObject {
    @Published public var muteSound = false
    
    public init() {}
}
