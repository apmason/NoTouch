//
//  AlertViewModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

protocol AlertObserver: class {
    func startAlerting()
    func stopAlerting()
}

class AlertViewModel {
    
    private var observations = [ObjectIdentifier : Observation]()
    
    private var audioVM = AudioAlert()
    
    // create timer
    private var lastFire: TimeInterval = Date().timeIntervalSince1970
    
    private var timer: Timer?
    
    // The number of seconds to wait to see if we should move out of the alert state.
    private let delayTime: TimeInterval = 0.35
    
    var audioIsMuted: Bool {
        get {
            return audioVM.isMuted
        } set {
            audioVM.isMuted = newValue
        }
    }
    
    public func setupAlerts() {
        addObserver(audioVM)
    }
    
    public func fireAlert() {
        lastFire = Date().timeIntervalSince1970
        
        // If a timer has been created that means that we are already firing an alert, so don't enter
        guard timer == nil else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: delayTime, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        
        // Observers will know whether they need to handle or not
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            DispatchQueue.main.async {
                observer.startAlerting()
            }
        }
    }
    
    @objc func fireTimer() {
        let now = Date().timeIntervalSince1970
        
        // More than `delayTime` has past. We have not received an update in the alloted period of time so stop everything.
        if (now - lastFire) > delayTime {
            timer?.invalidate()
            timer = nil
            
            // Stop firing
            for (id, observation) in observations {
                guard let observer = observation.observer else {
                    observations.removeValue(forKey: id)
                    continue
                }
                
                DispatchQueue.main.async {
                    observer.stopAlerting()
                }
            }
        }
        else {
            // Our timer has fired but we've received an update prior to the `delayTime` expiring
            // Create a new timer based on the last received update.
            timer?.invalidate()
            timer = nil
            
            let timeDifference: TimeInterval = now - lastFire
            let timeToWait = delayTime - timeDifference
        
            timer = Timer.scheduledTimer(timeInterval: timeToWait,
                                         target: self,
                                         selector: #selector(fireTimer),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
}

private extension AlertViewModel {
    struct Observation {
        weak var observer: AlertObserver?
    }
}

extension AlertViewModel {
    func addObserver(_ observer: AlertObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: AlertObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
