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
    private let delayTime: TimeInterval = 0.4
    
    var audioIsMuted: Bool {
        get {
            return audioVM.isMuted
        } set {
            audioVM.isMuted = newValue
        }
    }
    
    /// How many `fireAlert()` calls have we received? Once we reach the `triggerThreshold` we will send an alert to all observers and reset this value to 0.
    private var triggerCount = 0
    /// How many `fireAlert()` calls should be received before sending an alert to all observers.
    private var triggerThreshold = 3
    
    public func setupAlerts() {
        addObserver(audioVM)
    }
    
    public func fireAlert() {
        lastFire = Date().timeIntervalSince1970
        
        // If a timer has been created that means that we are already firing an alert, so don't enter.
        guard timer == nil else {
            return
        }
        
        // We only reach this point if firing has stopped and the timer has expired, therefore we want to do a threshold check.
        
        triggerCount += 1
        guard triggerCount >= triggerThreshold else {
            // We have not surpassed the threshold, return and wait for more triggers.
            return
        }
        
        // We can now fire an alert.
        triggerCount = 0
        
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
            
            let timeDifference: TimeInterval = now - lastFire
            let timeToWait = delayTime - timeDifference
        
            timer = Timer.scheduledTimer(timeInterval: timeToWait,
                                         target: self,
                                         selector: #selector(fireTimer),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    /// If a touching observation was made but was below our confidence threshold call this function. The `AlertViewModel` will update its internal state to determine when a real alert should be fired.
    public func notTouchingDetected() {
        // Triggers need to be successively succesful to avoid non-discrete random triggers from adding up and causing a trigger.
        triggerCount = 0
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
