//
//  DeviceData.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#endif

struct DeviceData {
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var deviceName: String {
        #if os(OSX)
        return Host.current().localizedName ?? ""
        #elseif os(iOS)
        return UIDevice.current.name
        #endif
    }
}
