//
//  VideoFeed.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AVFoundation
import Foundation
import VideoToolbox
import Vision

public protocol VideoFeedDelegate: class {
    func captureOutput(didOutput sampleBuffer: CMSampleBuffer)
}

// FIXME: Change this name to VideoFeedProvider? Or something of the sort?
public class VideoFeed: NSObject {
        
    private let session = AVCaptureSession()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput",
                                                     qos: .userInitiated,
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)
    
    private var currentDeviceInput: AVCaptureDeviceInput?
    
    private let previewView: NativewView
    // FIXME: No UIView's in this strange new world of ours.
    //private var coverView: UIView?
    
    private var devicePosition: AVCaptureDevice.Position? {
        return currentDeviceInput?.device.position
    }
    
    public weak var delegate: VideoFeedDelegate?
    
    public init(previewView: NativewView) {
        self.previewView = previewView
        super.init()
    }
    
    public func startup() {
        getCameraUsage()
    }
    
    func getCameraUsage() {
        CameraAuthModel.authorizeCameraForUsage { [weak self] result in
            switch result {
            case .success:
                CameraAuthModel.removeCameraRequirementOverlay()
                self?.setupAVCapture()
                self?.startCaptureSession()
                
            case .failure:
                CameraAuthModel.addCameraRequirementOverlay()
                
            }
        }
    }
    
    // The order of setup goes:
    // setupAVCapture
    // setupVision
    // setupCaptureSession
    
    func setupAVCapture() {
        // Select a video device and make an input.
        let inputDevice: AVCaptureDevice?
        
        // TODO: This should change.
        #if os(OSX)
        inputDevice = AVCaptureDevice.default(for: .video)
        #else
        inputDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video,
                                              position: .front)
        #endif
        
        guard let unwrappedInputDevice = inputDevice else {
            assertionFailure("Couldn't create video device.")
            return
        }
        
        do {
            currentDeviceInput = try AVCaptureDeviceInput(device: unwrappedInputDevice)
        } catch {
            print("Could not create video device input: \(error).")
            return
        }
        
        guard let deviceInput = currentDeviceInput else {
            assertionFailure("Can't create device")
            return
        }
        
        session.beginConfiguration()
        
        // The model input size is smaller than 640x480, so better resolution won't help us.
        session.sessionPreset = .vga640x480
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session.")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output.
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session.")
            session.commitConfiguration()
            return
        }

        session.commitConfiguration()
        
//        previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        guard let previewLayer = previewLayer else {
//            return
//        }
//        
//        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
//        previewLayer.connection?.isVideoMirrored = true
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        previewLayer.frame = previewView.nativeBounds
//        previewView.nativeLayer?.insertSublayer(previewLayer, at: 0)
    }
    
    public func updatePreviewLayerFrame(to rect: CGRect) {
        previewLayer?.frame = rect
        // FIXME: A way to update this right away?
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup.
    func teardownAVCapture() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
//    func changeCapturePosition(position: AVCaptureDevice.Position, completion: @escaping (Result<Void, NoTouchError>) -> Void) {
//        guard let currentInput = self.currentDeviceInput else {
//            completion(.failure(.noDeviceInput))
//            return
//        }
//
//        // FIXME: How to animate this? Should we pass a UIView in?
////        addCoverView()
////
////        let delay: TimeInterval = 0.2
////
////        UIView.animate(withDuration: delay, animations: { [weak self] in
////            self?.coverView?.alpha = 1
////        }) { [weak self] _ in
////            guard let self = self else {
////                return
////            }
////
////            self.session.removeInput(currentInput)
////
////            self.currentDeviceInput = nil
////
////            // create new device
////            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
////                self.removeCoverView()
////                completion(.failure(.inputDeviceCreationFailure))
////                return
////            }
////
////            do {
////                self.currentDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
////            } catch {
////                print("Could not create video device input: \(error).")
////                self.removeCoverView()
////                completion(.failure(.inputDeviceCreationFailure))
////                return
////            }
////
////            guard let newInput = self.currentDeviceInput else {
////                self.removeCoverView()
////                completion(.failure(.inputDeviceCreationFailure))
////                return
////            }
////
////            guard self.session.canAddInput(newInput) else {
////                print("Could not add video device input to the session.")
////                self.removeCoverView()
////                self.session.commitConfiguration()
////                completion(.failure(.inputDeviceCreationFailure))
////                return
////            }
////
////            self.session.addInput(newInput)
////            self.session.commitConfiguration()
////
////            UIView.animate(withDuration: delay, animations: { [weak self] in
////                self?.coverView?.alpha = 0
////
////            }) { [weak self] _ in
////                self?.removeCoverView()
////                completion(.success(()))
////
////            }
////        }
//    }
    
    // FIXME: Make a protocol that can handle UIViews and NSViews.
    func addCoverView() {
//        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
//        coverView = UIVisualEffectView(effect: blurEffect)
//        
//        coverView?.translatesAutoresizingMaskIntoConstraints = false
//        
//        guard let coverView = coverView else {
//            return
//        }
//        
//        coverView.backgroundColor = UIColor.white
//        coverView.alpha = 0
        
        // FIXME: SwiftUI may be able to add the cover view.
//        previewView.addSubview(coverView)
//
//        NSLayoutConstraint.activate([
//            coverView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
//            coverView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
//            coverView.topAnchor.constraint(equalTo: previewView.topAnchor),
//            coverView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor)
//        ])
    }
    
    // FIXME: Nothing is getting removed now
    func removeCoverView() {
//        coverView?.removeFromSuperview()
//        coverView = nil
    }
    
    // FIXME: This should be in the iOS side only (Mac won't flip)
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer?.frame = previewView.bounds
//
//        switch UIDevice.current.orientation {
//        case .landscapeLeft:
//            previewLayer?.connection?.videoOrientation = .landscapeRight
//
//        case .landscapeRight:
//            previewLayer?.connection?.videoOrientation = .landscapeLeft
//
//        case .portrait:
//            previewLayer?.connection?.videoOrientation = .portrait
//
//        case .portraitUpsideDown:
//            previewLayer?.connection?.videoOrientation = .portraitUpsideDown
//
//        default:
//            return
//
//        }
//    }
}

extension VideoFeed: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // FIXME: Kick this back to the VisionModel somehow.
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(didOutput: sampleBuffer)
    }
}
