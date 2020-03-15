//
//  CameraAuthModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class CameraAuthModel {
    
    // A wrapper enum to simplify our tracking of camera auth states
    enum CameraAuthState {
        case authorized
        case notDetermined
        case denied
    }
    
    // If non-nil this is the currently presented CameraRequirementAlertView.
    static var alertView: AlertView?
    
    static func authorizeCameraForUsage(completion: @escaping ((Result<Void, NTError>) -> Void)) {
        
        switch determineIfAuthorized() {
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
            
        case .denied:
            completion(.failure(NTError.cameraAccessDenied))
            
        }
    }
    
    /// A wrapper around `AVCaptureDevice.authorizationStatus(for:)` that returns a simplified enum, `CameraAuthState`
    static func determineIfAuthorized() -> CameraAuthState {
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
    
    // Present the camera requirement screen to the user.
    static func addCameraRequirementOverlay() {
        guard alertView == nil, let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            print("Alert view exists or keyWindow failed")
            return
        }
        
        if var topController = keyWindow.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            // load Xib.
            guard let av: AlertView = Bundle.main.loadNibNamed("AlertView",
                                                               owner: nil,
                                                               options: nil)?.first as? AlertView
                else {
                print("No alert view")
                return
            }
            
            self.alertView = av
            
            guard let alertView = self.alertView else {
                return
            }
            
            alertView.translatesAutoresizingMaskIntoConstraints = false
            topController.view.addSubview(alertView) // Is the VisionViewController's `view` property all fucked up? Will this work right?
            
            NSLayoutConstraint.activate([
                alertView.topAnchor.constraint(equalTo: topController.view.topAnchor),
                alertView.bottomAnchor.constraint(equalTo: topController.view.bottomAnchor),
                alertView.leadingAnchor.constraint(equalTo: topController.view.leadingAnchor),
                alertView.trailingAnchor.constraint(equalTo: topController.view.trailingAnchor)
            ])
        }
    }
    
    static func removeCameraRequirementOverlay() {
        alertView?.removeFromSuperview()
        alertView = nil
    }
}
