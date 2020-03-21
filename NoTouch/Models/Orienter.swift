//
//  Orienter.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/21/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation
import UIKit

class Orienter {
    
    /// Based on the current device orientation calculate the desired CGImagePropertyOrientation
    /// - Returns: The orientation
    public static func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        // TODO: Needs to be fixed to handle all orientations. (front and back facing camera)
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, Home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, Home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, Home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, Home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
