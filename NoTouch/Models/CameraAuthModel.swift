//
//  CameraAuthModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import AVFoundation
import Foundation

class CameraAuthModel {
    
    // A wrapper enum to simplify our tracking of camera auth states
    enum CameraAuthState {
        case authorized
        case notDetermined
        case denied
    }
    
    static func authorizeCameraForUsage(completion: @escaping ((Result<Void, NTError>) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                completion(.success(()))
            }
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .success(()) : .failure(NTError.cameraAccessDenied))
                }
            }
            
        case .denied, .restricted: // The user has previously denied access or the user can't grant access due to restrictions
            completion(.failure(NTError.cameraAccessDenied))
            
        default:
            return
        }
    }
    
    static func determineIfAuthorized(completion: @escaping ((CameraAuthState) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(.authorized)
            
        case .notDetermined:
            completion(.notDetermined)
            
        case .denied, .restricted:
            completion(.denied)
            
        default:
            completion(.denied)
            
        }
    }
    
    // Present the camera requirement screen to the user.
    static func showCameraRequirementScreen() {
        
    }
}
