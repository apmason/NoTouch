//
//  CameraAuthModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/13/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AVFoundation
import Foundation
// FIXME: Do we need to do this here?
#if os(iOS)
import UIKit
#endif

public class CameraAuthModel {
    
    // A wrapper enum to simplify our tracking of camera auth states
    public enum CameraAuthState {
        case authorized
        case notDetermined
        case denied
    }
    
    // If non-nil this is the currently presented CameraRequirementAlertView.
    // FIXME: Can we do the below AlertView in SwiftUI?
    //static var alertView: AlertView?
    
    static func authorizeCameraForUsage(completion: @escaping ((Result<Void, NoTouchError>) -> Void)) {
        switch determineIfAuthorized() {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                completion(.success(()))
            }
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .success(()) : .failure(NoTouchError.cameraAccessDenied))
                }
            }
            
        case .denied:
            completion(.failure(NoTouchError.cameraAccessDenied))
            
        }
    }
    
    /// A wrapper around `AVCaptureDevice.authorizationStatus(for:)` that returns a simplified enum, `CameraAuthState`
    public static func determineIfAuthorized() -> CameraAuthState {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
            
        case .notDetermined:
            return .notDetermined
            
        case .denied, .restricted:
            return .denied
            
        default:
            return .denied
            
        }
    }
}
