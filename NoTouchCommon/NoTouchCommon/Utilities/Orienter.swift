//
//  Orienter.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/21/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import Foundation
#if os(iOS)
import AVFoundation
import UIKit
#endif

class Orienter {
    
    // FIXME: if running on iOS do this calculation, otherwise always be up and mirrored (Mac won't rotate)
    // This is half implemented, does it work?
    
    /// Based on the current device orientation calculate the desired CGImagePropertyOrientation
    /// - Returns: The orientation
    public static func currentCGOrientation() -> CGImagePropertyOrientation {
        #if os(iOS)
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
        
        // NOTE: Mac will ALWAYS be up. Do all calculations as if things were 'up' and NOT mirrored, just adjust the UI to make things look mirrored.
        #elseif os(OSX)
        return .up
        #endif
    }
    
    #if os(iOS)
    public static var videoOrientation: AVCaptureVideoOrientation? {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft:       // Device oriented horizontally, Home button on the right
        return .landscapeRight
        case .landscapeRight:      // Device oriented horizontally, Home button on the left
        return .landscapeLeft
        case .portrait:            // Device oriented vertically, Home button on the bottom
        return .portrait
        
        case .portraitUpsideDown:
        return nil
        default:
        return .portrait
        }
    }
    #endif
}
