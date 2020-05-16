//
//  CloudKitRetryManager.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Network
import Foundation

public protocol RetryManagerDelegate: class {
    func networkStateDidChange(_ networkAvailable: Bool)
}

public protocol RetryManager: class {
    var monitor: NWPathMonitor { get }
    var networkIsUp: Bool { get }
    var delegate: RetryManagerDelegate? { get set }
}

class CloudKitRetryManager: RetryManager {
    
    weak var delegate: RetryManagerDelegate?
    
    let monitor = NWPathMonitor()
    
    var networkIsUp: Bool = false
    
    let queue = DispatchQueue(label: "com.handsOff.common.pathMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.networkIsUp = path.status == .satisfied
            self?.delegate?.networkStateDidChange(path.status == .satisfied)
        }
        
        monitor.start(queue: queue)
    }
}
