//
//  CloudKitRetryManager.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Network
import Foundation

public protocol NetworkMonitorDelegate: class {
    func networkStateDidChange(_ networkAvailable: Bool)
}

public class NetworkMonitor {
    
    weak var delegate: NetworkMonitorDelegate?
    
    let monitor = NWPathMonitor()
        
    let queue = DispatchQueue(label: "com.NoTouch.common.pathMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.delegate?.networkStateDidChange(path.status == .satisfied)
        }
        
        monitor.start(queue: queue)
    }
}
