//
//  TrainingImage.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/21/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import CoreML
import Foundation

/// A convenience structure that stores a CGImage that was collected for model fine tuning.
struct TrainingImage {
    
    let cgImage: CGImage
    let imageConstraint: MLImageConstraint
    let orientation: CGImagePropertyOrientation
    
    var featureValue: MLFeatureValue? {
        do {
            return try MLFeatureValue(cgImage: cgImage, orientation: orientation, constraint: imageConstraint, options: nil)
        } catch {
            print("Error creating feature value: \(error.localizedDescription)")
            return nil
        }
    }
}
