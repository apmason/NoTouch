//
//  ImageFeatureProvider.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/21/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreML
import Foundation

class ImageFeatureProvider {
    
    enum OutputValue: String {
        case touching = "Touching"
        case notTouching = "Not_Touching"
    }
    
    private let outputValue: OutputValue
    private var trainingImages: [TrainingImage] = []
    
    fileprivate let inputKey = "mobilenetv2_1.00_224_input"
    fileprivate let outputKey = "classLabel"
    
    init(outputValue: OutputValue) {
        self.outputValue = outputValue
    }
   
    public func addTrainingImage(_ trainingImage: TrainingImage) {
        self.trainingImages.append(trainingImage)
    }
    
    public func createFeatureProviders() -> [MLFeatureProvider] {
        var featureProviders: [MLFeatureProvider] = []
        for image in trainingImages {
            if let inputFeature = image.featureValue {
                let outputFeature = MLFeatureValue(string: outputValue.rawValue)
                
                let featureDictionary: [String: MLFeatureValue] = [
                    inputKey: inputFeature,
                    outputKey: outputFeature
                ]
                
                do {
                    let provider = try MLDictionaryFeatureProvider(dictionary: featureDictionary)
                    featureProviders.append(provider)
                } catch {
                    print("Error creating MLDictionaryFeatureProvider: \(error)")
                }
            }
        }
        
        print("Feature provider count is: \(featureProviders.count)")
        return featureProviders
    }
    
    public func clearOutTrainingImages() {
        trainingImages = []
    }
}
