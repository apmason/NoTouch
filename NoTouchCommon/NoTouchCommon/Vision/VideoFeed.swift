//
//  VideoFeed.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AppKit
import AVFoundation
import Combine
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
    
    private var devicePosition: AVCaptureDevice.Position? {
        return currentDeviceInput?.device.position
    }
    
    public weak var delegate: VideoFeedDelegate?
    
    private var cancellableObservation: AnyCancellable?
    
    /// Cache the last view that had it's layer set as the preview layer. We will use this when turning on and off the camera feed.
    private var nativeView: NSView?
//    func addAudioObserver() {
//        addObserver(audioVM)
//
//        cancellableObservation = userSettings.$muteSound.sink { muteSound in
//            self.audioIsMuted = muteSound
//        }
//    }
    
    public init(userSettings: UserSettings) {
        super.init()
        
        cancellableObservation = userSettings.$hideCameraFeed.sink(receiveValue: { hideCameraFeed in
            if !hideCameraFeed {
                // add feed
                self.teardownPreviewLayer()
            } else {
                // don't add feed
                guard let view = self.nativeView else {
                    return
                }
                
                self.setPreviewView(to: view, withRect: view.bounds)
            }
        })
    }
    
    public func startup() {
        getCameraUsage()
    }
    
    /// Determine if a user can use the camera or not. If a user can use the camera proceed with settings up the capture session. If they cannot, add a message telling the user that they need to authorize camera usage.
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
    
    /// Setup the video device inputs and capture session.
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
    }
    
    /// Resets the `VideoFeed`'s `previewLayer` property, and sets it to fit within the `nativeView`'s bounds, and inserts it as a layer.
    public func setPreviewView(to nativeView: NSView, withRect rect: CGRect) {
        self.nativeView = nativeView
        DispatchQueue.main.async {
            guard let previewLayer = self.previewLayer else {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
                self.previewLayer?.connection?.isVideoMirrored = true
                self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewLayer?.frame = nativeView.bounds
                nativeView.layer = self.previewLayer
                nativeView.wantsLayer = true
                return
            }
            
            if nativeView.layer == previewLayer {
                previewLayer.frame = nativeView.bounds
                if !(previewLayer.connection?.isVideoMirrored ?? false) {
                    //assertionFailure("What are you doing?")
                }
            } else {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
                self.previewLayer?.connection?.isVideoMirrored = true
                self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewLayer?.frame = nativeView.bounds
                self.previewLayer?.removeFromSuperlayer()
                nativeView.layer = self.previewLayer
            }
        }
    }
    
    /// Remove the previewLayer from any super layer and destroy it.
    func teardownPreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
    public func updatePreviewLayerFrame(to rect: CGRect) {
        previewLayer?.frame = rect
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoFeed: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // FIXME: Kick this back to the VisionModel somehow.
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(didOutput: sampleBuffer)
    }
}

//// THINGS TO DO:
//
////    func changeCapturePosition(position: AVCaptureDevice.Position, completion: @escaping (Result<Void, NoTouchError>) -> Void) {
////        guard let currentInput = self.currentDeviceInput else {
////            completion(.failure(.noDeviceInput))
////            return
////        }
////
////        // FIXME: How to animate this? Should we pass a UIView in?
//////        addCoverView()
//////
//////        let delay: TimeInterval = 0.2
//////
//////        UIView.animate(withDuration: delay, animations: { [weak self] in
//////            self?.coverView?.alpha = 1
//////        }) { [weak self] _ in
//////            guard let self = self else {
//////                return
//////            }
//////
//////            self.session.removeInput(currentInput)
//////
//////            self.currentDeviceInput = nil
//////
//////            // create new device
//////            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
//////                self.removeCoverView()
//////                completion(.failure(.inputDeviceCreationFailure))
//////                return
//////            }
//////
//////            do {
//////                self.currentDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//////            } catch {
//////                print("Could not create video device input: \(error).")
//////                self.removeCoverView()
//////                completion(.failure(.inputDeviceCreationFailure))
//////                return
//////            }
//////
//////            guard let newInput = self.currentDeviceInput else {
//////                self.removeCoverView()
//////                completion(.failure(.inputDeviceCreationFailure))
//////                return
//////            }
//////
//////            guard self.session.canAddInput(newInput) else {
//////                print("Could not add video device input to the session.")
//////                self.removeCoverView()
//////                self.session.commitConfiguration()
//////                completion(.failure(.inputDeviceCreationFailure))
//////                return
//////            }
//////
//////            self.session.addInput(newInput)
//////            self.session.commitConfiguration()
//////
//////            UIView.animate(withDuration: delay, animations: { [weak self] in
//////                self?.coverView?.alpha = 0
//////
//////            }) { [weak self] _ in
//////                self?.removeCoverView()
//////                completion(.success(()))
//////
//////            }
//////        }
////    }
//
//    // FIXME: Make a protocol that can handle UIViews and NSViews.
//    func addCoverView() {
////        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
////        coverView = UIVisualEffectView(effect: blurEffect)
////
////        coverView?.translatesAutoresizingMaskIntoConstraints = false
////
////        guard let coverView = coverView else {
////            return
////        }
////
////        coverView.backgroundColor = UIColor.white
////        coverView.alpha = 0
//
//        // FIXME: SwiftUI may be able to add the cover view.
////        previewView.addSubview(coverView)
////
////        NSLayoutConstraint.activate([
////            coverView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
////            coverView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
////            coverView.topAnchor.constraint(equalTo: previewView.topAnchor),
////            coverView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor)
////        ])
//    }
//
//    // FIXME: Nothing is getting removed now
//    func removeCoverView() {
////        coverView?.removeFromSuperview()
////        coverView = nil
//    }
//
//    // FIXME: This should be in the iOS side only (Mac won't flip)
////    override func viewDidLayoutSubviews() {
////        super.viewDidLayoutSubviews()
////        previewLayer?.frame = previewView.bounds
////
////        switch UIDevice.current.orientation {
////        case .landscapeLeft:
////            previewLayer?.connection?.videoOrientation = .landscapeRight
////
////        case .landscapeRight:
////            previewLayer?.connection?.videoOrientation = .landscapeLeft
////
////        case .portrait:
////            previewLayer?.connection?.videoOrientation = .portrait
////
////        case .portraitUpsideDown:
////            previewLayer?.connection?.videoOrientation = .portraitUpsideDown
////
////        default:
////            return
////
////        }
////    }
