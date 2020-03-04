//
//  AlertViewModel.swift
//  FlowerShop
//
//  Created by Alexander Mason on 3/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

protocol AlertObserver: class {
    func alertDidFire(withTimeoutPeriod timeoutPeriod: TimeInterval)
}

class AlertViewModel {
    
    private var canFire = true
    private var timeoutPeriod: TimeInterval = 3
    private var observations = [ObjectIdentifier : Observation]()
    
    private var audioVM = AudioAlert()
    
    public func setupAlerts() {
        addObserver(audioVM)
    }
    
    public func fireAlert() {
        guard canFire else {
            return
        }
        
        canFire = false
        
        // Observers will know whether they need to handle or not
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            DispatchQueue.main.async {
                observer.alertDidFire(withTimeoutPeriod: self.timeoutPeriod)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutPeriod) { [weak self] in
            self?.canFire = true
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
