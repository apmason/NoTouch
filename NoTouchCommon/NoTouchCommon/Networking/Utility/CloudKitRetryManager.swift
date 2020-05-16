//
//  CloudKitRetryManager.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Network
import Foundation

public protocol RetryManager {
    var monitor: NWPathMonitor { get }
    var networkIsUp: Bool { get }
}

class CloudKitRetryManager: RetryManager {
    let monitor = NWPathMonitor()
    
    var networkIsUp: Bool = false
    
    let queue = DispatchQueue(label: "com.handsOff.common.pathMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.networkIsUp = path.status == .satisfied
        }
        
        monitor.start(queue: queue)
    }
    
    /**
     - Monitor network.
        - For sending: see if the network is up, if so send, handle errors appropriately if things fail.
        - If network is _not up_ cache records, send when back up. As a batch.

     - For a network failure, do an auto retry.
     - Monitor the network, when it comes back on, make the call to fetch all records.
        - This relies on us only adding unique records to the UserSettings.RecordHolder.
        -
     */
}
