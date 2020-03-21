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
        case priming
        case collectingTouching
        case collectingNotTouching
        
        var nextState: CollectionState {
            switch self {
            case .notCollecting:
                return .priming
                
            case .priming:
                return .collectingTouching
                
            case .collectingTouching:
                return .collectingNotTouching
                
            case .collectingNotTouching:
                return .notCollecting
            }
        }
    }
    
    var isCollecting: Bool {
        return !(collectionState == .notCollecting)
    }
 
    private var collectionState: CollectionState = .notCollecting
    
    private let originalModel: MLModel
    
    weak var delegate: ModelUpdaterDelegate?
    
    // We are assuming that imageHeight is always == imageWidth
    private var imageHeight: Int {
        return originalModel.modelDescription.inputDescriptionsByName["image"]?.imageConstraint?.pixelsHigh ?? 0
    }
    
    init(originalModel: MLModel, delegate: ModelUpdaterDelegate) {
        self.originalModel = originalModel
        self.delegate = delegate
        
        print("Inputs: \(originalModel.modelDescription.inputDescriptionsByName)")
        print("Outputs: \(originalModel.modelDescription.outputDescriptionsByName)")
        print("Image height is: \(imageHeight)")
    }
    
    public func startCollecting() {
        collectionState = .priming
        
        let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] timer in
            timer.invalidate()
            guard let self = self else {
                return
            }
            
            self.collectionState = self.collectionState.nextState
        }
    }
    
    public func addImage(_ cgImage: CGImage) {
//        let imageFeatureValue = try? MLFeatureValue(cgImage: preparedImage,
//                                                    constraint: imageConstraint)
        //let new = try? MLFeatureValue(
        
    }
    
}
