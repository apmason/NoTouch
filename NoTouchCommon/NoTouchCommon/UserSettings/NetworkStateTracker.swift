//
//  NetworkStateTracker.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/17/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public struct NetworkStateTracker {
    public var cloudKitAuthStatus: DatabaseAuthStatus = .unknown
    public var isNetworkAvailable = true
}
