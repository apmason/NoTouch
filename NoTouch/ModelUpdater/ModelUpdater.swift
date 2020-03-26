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
    // TODO: Add new delegate method here to alert when we start training?
}

/// Handles the model's state machine.
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
 
    /// The state machine that tracks the collection state. When a new value is set, when applicable, a new timer is kicked off to update the state after an allotted period of time.
    private(set) var collectionState: CollectionState = .notCollecting {
        didSet {
            print("Collection state updated to: \(collectionState)")
            switch collectionState {
            case .notCollecting:
                
                // We just finished a cycle, create the batch
                if oldValue == .collectingNotTouching {
                    createBatchProvider()
                }
                
                break
                
            case .primingTouching:
                rotateStateAfter(seconds: 3)
                
            case .collectingTouching:
                rotateStateAfter(seconds: 3)
                
            case .primingNotTouching:
                rotateStateAfter(seconds: 3)
                
            case .collectingNotTouching:
                rotateStateAfter(seconds: 3)
                
            }
        }
    }
    
    /// The model that the app comes packaged with. We will always train off of this model. A user can update the model from a new position/scenario only once, we won't keep track of multiple new fine tunings (fearing that it may screw things up, overfit, not work great).
    private let originalModel: MLModel
    
    /// The URL of the original model to be used when fine tuning.
    private let originalModelURL: URL
    
    weak var delegate: ModelUpdaterDelegate?
    
    // Touching and NotTouching will share these values.
    fileprivate let inputName = "mobilenetv2_1.00_224_input"
    
    private var imageInputConstraint: MLImageConstraint {
        guard let constraint = originalModel
            .modelDescription
            .inputDescriptionsByName[inputName]?
            .imageConstraint
        else {
            fatalError("Could not find the original model's input constraint")
        }
        
        return constraint
    }
    
    // TODO: Add touching image feature batch
    
    // TODO: Add not touching image feature batch
    
    init(originalModel: MLModel, originalModelURL: URL, delegate: ModelUpdaterDelegate) {
        self.originalModel = originalModel
        self.originalModelURL = originalModelURL
        self.delegate = delegate
    }
    
    /// Kick off the model fine tuning flow.
    public func startCollecting() {
        collectionState = .primingTouching
    }
    
    /// Feed in an image that is to be used in fine-tuning the touching model. The model's internal state will determine how the image should be classified ('Touching' or 'Not_Touching').
    /// The model may internally decide not to use a `cgImage` that was input if the state machine is not in the proper state.
    /// The caller need not worry about the internal state of the model, the model will handle that.
    /// The caller also shouldn't transform the image's orientation, the model will handle that.
    /// - Parameter cgImage: An unaltered `CGImage` object. Do not transform/transpose the image, the model will handle orientations when it needs to.
    public func addImage(_ cgImage: CGImage) {
        // Only collect images while actually collecting.
        guard (collectionState == .collectingTouching || collectionState == .collectingNotTouching) else {
            return
        }
        
        let trainingImage = TrainingImage(cgImage: cgImage,
                                          imageConstraint: imageInputConstraint,
                                          orientation: Orienter.currentCGOrientation())
        
        if collectionState == .collectingTouching {
            touchingProvider.addTrainingImage(trainingImage)
        }
        else if collectionState == .collectingNotTouching {
            notTouchingProvider.addTrainingImage(trainingImage)
        }
    }
    
    // TODO: Add an optional completion?
    private func rotateStateAfter(seconds: TimeInterval) {
        let _ = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] timer in
            timer.invalidate()
            guard let self = self else {
                return
            }
            
            self.collectionState = self.collectionState.nextState
        }
    }
    
    // MARK: - Data Collection
    
    private let touchingProvider = ImageFeatureProvider(outputValue: .touching)
    private let notTouchingProvider = ImageFeatureProvider(outputValue: .notTouching)
    
    func createBatchProvider() {
        let providers = touchingProvider.createFeatureProviders() + notTouchingProvider.createFeatureProviders()
        let batchProvider = MLArrayBatchProvider(array: providers)
        
        updateModel(with: batchProvider)
    }
}

// MARK: - CoreML Functions

extension ModelUpdater {
    
    func updateModel(with trainingData: MLBatchProvider) {
        
        let handlers = MLUpdateProgressHandlers(forEvents: [.epochEnd, .trainingBegin, .miniBatchEnd], progressHandler: { (context) in
            print("In this context: \(context.event)")
        }) { (finalContext) in
            print("In final context")
        }
        
        do {
            let updateTask = try MLUpdateTask(forModelAt: originalModelURL, trainingData: trainingData, configuration: nil, progressHandlers: handlers)
            updateTask.resume()
        } catch {
            print("Error in update task: \(error.localizedDescription)")
        }
        
        //let updateTask = try? MLUpdateTask(forModelAt: originalModelURL,
                                           //trainingData: trainingData,
                                           //configuration: nil,
                                           //completionHandler: { context in
                                            //print("We made it bitch")
                                            //print("Context event: \(context.event)")
                                            
                                         //   let updatedModel = context.model
                                            // create a new directory for the model
                                            // write to the directroy
                                            // replace any previously updated model with new one
                                            
                                            /** EXAMPLE BELOW */
//                                            do {
//                                                // Create a directory for the updated model.
//                                                try fileManager.createDirectory(at: tempUpdatedModelURL,
//                                                                                withIntermediateDirectories: true,
//                                                                                attributes: nil)
//
//                                                // Save the updated model to temporary filename.
//                                                try updatedModel.write(to: tempUpdatedModelURL)
//
//                                                // Replace any previously updated model with this one.
//                                                _ = try fileManager.replaceItemAt(updatedModelURL,
//                                                                                  withItemAt: tempUpdatedModelURL)
//
//                                                print("Updated model saved to:\n\t\(updatedModelURL)")
//                                            } catch let error {
//                                                print("Could not save updated model to the file system: \(error)")
//                                                return
//                                            }
                                            /** EXAMPLE END */
                                            
                                            // alert delegate that we've updated
                                            // In the delegate we now need to update our faceTouchingRequest with this new model.
                                            
                                            // TODO: Empty out the arrays of training data.
      //  })
        
    }
}
