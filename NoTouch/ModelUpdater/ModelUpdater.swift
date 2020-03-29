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
    func loadModelWithURL(_ url: URL)
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
    
    var finalConversion: Bool = false
 
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
                rotateStateAfter(seconds: 5)
                
            case .primingNotTouching:
                rotateStateAfter(seconds: 3)
                
            case .collectingNotTouching:
                rotateStateAfter(seconds: 5)
                
            }
        }
    }
    
    /// The model that the app comes packaged with. We will always train off of this model. A user can update the model from a new position/scenario only once, we won't keep track of multiple new fine tunings (fearing that it may screw things up, overfit, not work great).
    private let originalModel: MLModel
    
    /// The URL of the original model to be used when fine tuning.
    private let originalModelURL: URL
    
    /// The file manager being used to save and read files
    private static let fileManager = FileManager.default
    
    /// The location of the app's Application Support directory for the user.
    private static var appDirectory: URL? {
        return fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }
    
    /// The temporary location of the updated Drawing Classifier model
    private static var tempUpdatedModelURL: URL? {
        return appDirectory?.appendingPathComponent("personalize_tmp.mlmodelc")
    }
    
    /// The location of the user's latest updated model
    private static var updatedModelURL: URL? {
        return appDirectory?.appendingPathComponent("perzonalized.mlmodelc")
    }
    
    /// The existing updated model. This means that the URL exists AND that a file exists at this location.
    public static var existingUpdatedURL: URL? {
        guard let modelURL = updatedModelURL else {
            return nil
        }
        
        // If a file exists at the modelURL return that URL, otherwise return nil.
        return fileManager.fileExists(atPath: modelURL.path) ? modelURL : nil
    }
    
    weak var delegate: ModelUpdaterDelegate?
    
    fileprivate let inputName = "image"
    
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
    
    init(originalModel: MLModel, originalModelURL: URL, delegate: ModelUpdaterDelegate) {
        self.originalModel = originalModel
        self.originalModelURL = originalModelURL
        self.delegate = delegate
    }
    
    deinit {
        print("Releasing this")
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
        
        print("An image has been added")
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
        finalConversion = true
        
        let progressHandlers = MLUpdateProgressHandlers(forEvents: [.trainingBegin, .epochEnd, .miniBatchEnd], progressHandler: { (context) in
            switch context.event {
            case .epochEnd:
                print("Epoch end")
                
            case .miniBatchEnd:
                //print("Mini batch end")
                break
                
            case .trainingBegin:
                print("Training began")
                
            default:
                print("Default case")
                
            }
        }) { [weak self] (context) in
            print("in final completion")
            let updatedModel = context.model

            let fileManager = FileManager.default
            guard let tempUpdatedModelURL = ModelUpdater.tempUpdatedModelURL,
                let updatedModelURL = ModelUpdater.updatedModelURL else {
                    return
            }
            
            do {
                // Create a directory for the updated model.
                try fileManager.createDirectory(at: tempUpdatedModelURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                
                // Save the updated model to temporary filename.
                try updatedModel.write(to: tempUpdatedModelURL)
                
                // Replace any previously updated model with this one.
                _ = try fileManager.replaceItemAt(updatedModelURL,
                                                  withItemAt: tempUpdatedModelURL)
                
                self?.delegate?.loadModelWithURL(updatedModelURL)
                
                // TODO: - If a user starts the app again load their trained model. (Save to UserDefaults to know latest?)
                print("Updated model saved to:\n\t\(updatedModelURL)")
            } catch let error {
                print("Could not save updated model to the file system: \(error)")
                return
            }
        }
        
        do {
            let updateTask = try MLUpdateTask(forModelAt: originalModelURL, trainingData: trainingData, configuration: nil, progressHandlers: progressHandlers)
            updateTask.resume()
        } catch {
            print("Error creating MLUpdateTask: \(error.localizedDescription)")
        }
        
//        let updateTask = try? MLUpdateTask(forModelAt: originalModelURL,
//                                           trainingData: trainingData,
//                                           configuration: nil,
//                                           completionHandler: { [weak self] context in
//                                            print("We made it bitch")
//                                            self?.touchingProvider.clearOutTrainingImages()
//                                            self?.notTouchingProvider.clearOutTrainingImages()
//                                            print("Context event: \(context.event.rawValue)")
//                                            self?.finalConversion = false
//
//                                            // TODO: Progress bar in here using different completion?
//
//                                            let updatedModel = context.model
//                                            let fileManager = FileManager.default
//                                            guard let tempUpdatedModelURL = self?.tempUpdatedModelURL,
//                                                let updatedModelURL = self?.updatedModelURL else {
//                                                    return
//                                            }
//
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
//                                                // TODO: - If a user starts the app again load there trained model. (Save to UserDefaults to know latest?)
//                                                print("Updated model saved to:\n\t\(updatedModelURL)")
//                                            } catch let error {
//                                                print("Could not save updated model to the file system: \(error)")
//                                                return
//                                            }
//
//                                            self?.delegate?.didUpdateMLModelToUse(context.model)
//
//        })
    }
}
