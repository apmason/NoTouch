//
//  ModelUpdater.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/20/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import CoreML
import Foundation

// Things needed to be done.
// Button on the side of the screen (we should always save the original model and let a user update for a specific circumstance (retrain))
// UI updates to explain to the user what is happening (countdown, sounds)
// Collect a group for touching photos, a group for not touching photos
// Feed that data into a Model class that will turn it into the proper CoreML objects
// Retrain the data
// Activity Indicator/Waiting for the model to update
// Reset which model is being used

protocol ModelUpdaterDelegate: class {
    func startPrimingTouching()
    func startPrimingNotTouching()
    func startCollectingTouching()
    func startCollectingNotTouching()
}

class ModelUpdater {
    
    enum CollectionState {
        case notCollecting
        case primingTouching
        case primingNotTouching
        case collectingTouching
        case collectingNotTouching
        
        /**
         The state machine operates in this way:
         
         - Starts at notCollecting (we're doing nothing).
         - Then it moves to primingTouching.
         - Then it moves to collectTouching and starts collecting touching input images.
         - Then it moves to primingNotTouching.
         - Then it moves to collectingNotTouching and starts collecting not touching input images.
         - Then we are done and move back to the start position.
         */
        var nextState: CollectionState {
            switch self {
            case .notCollecting:
                return .primingTouching
                
            case .primingTouching:
                return .collectingTouching
                
            case .collectingTouching:
                return .primingNotTouching

            case .primingNotTouching:
                return .collectingNotTouching
                
            case .collectingNotTouching:
                return .notCollecting
            }
        }
    }
    
    /// Should this object be sent image data? This conditional is more wide-ranging than need be (we are saying to collect while priming here). But internally we can decide when to collect images (discard images collected while priming), we're more so instructing others not to identify touches.
    var isCollecting: Bool {
        return !(collectionState == .notCollecting)
    }
 
    /// The state machine that tracks the collection state. When a new value is set, when applicable, a new timer is kicked off to update the state after an alloted period of time.
    private var collectionState: CollectionState = .notCollecting {
        didSet {
            switch collectionState {
            case .notCollecting:
                break
                
            case .primingTouching:
                rotateStateAfter(seconds: 3)
                
            case .collectingTouching:
                rotateStateAfter(seconds: 10)
                
            case .primingNotTouching:
                rotateStateAfter(seconds: 3)
                
            case .collectingNotTouching:
                rotateStateAfter(seconds: 10)
                
            }
        }
    }
    
    /// The model that the app comes packaged with. We will always train off of this model. A user can update the model from a new position/scenario only once, we won't keep track of multiple new fine tunings (fearing that it may screw things up, overfit, not work great).
    private let originalModel: MLModel
    
    weak var delegate: ModelUpdaterDelegate?
    
    private var imageInputConstraint: MLImageConstraint {
        guard let constraint = originalModel
            .modelDescription
            .inputDescriptionsByName["image"]?
            .imageConstraint
        else {
            fatalError("Could not find the original model's input constraint")
        }
        
        return constraint
    }
    
    // TODO: Add touching image feature batch
    
    // TODO: Add not touching image feature batch
    
    init(originalModel: MLModel, delegate: ModelUpdaterDelegate) {
        self.originalModel = originalModel
        self.delegate = delegate
    }
    
    public func startCollecting() {
        collectionState = .primingNotTouching
    }
    
    public func addImage(_ cgImage: CGImage) {
        // Only collect images while actually collecting.
        guard (collectionState == .collectingTouching || collectionState == .collectingNotTouching) else {
            return
        }
        
        let trainingImage = TrainingImage(cgImage: cgImage, imageConstraint: imageInputConstraint, orientation: Orienter.exifOrientationFromDeviceOrientation())
        print("Have training image here")
    }
    
    private func rotateStateAfter(seconds: TimeInterval) {
        let _ = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] timer in
            timer.invalidate()
            guard let self = self else {
                return
            }
            
            self.collectionState = self.collectionState.nextState
        }
    }
}
