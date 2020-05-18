//
//  VideoFeed.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

//import AppKit
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
    
    /// Tracks if we should be showing the video output.
    private var cancellableObservation: AnyCancellable?
    
    /// Tracks if we should be pausing/playing the feed.
    private var detectionObservation: AnyCancellable?
    
    /// Cache the last view that had it's layer set as the preview layer. We will use this when turning on and off the camera feed.
    private var nativeView: NativeView?
    
    private let userSettings: UserSettings
    
    public init(userSettings: UserSettings) {
        self.userSettings = userSettings
        super.init()
        
        cancellableObservation = userSettings.$hideCameraFeed.sink(receiveValue: { hideCameraFeed in
            if hideCameraFeed {
                // add feed
                self.teardownPreviewLayer()
            } else {
                self.setNativeViewLayerIfNeeded()
            }
        })
        
        detectionObservation = userSettings.$pauseDetection.sink(receiveValue: { [weak self] pause in
            guard let self = self else {
                return
            }
            
            // Tear everything down.
            if pause {
                self.session.stopRunning()
                self.teardownPreviewLayer()
            }
            else { // Activate everything
                self.setupSessionForUsage()
            }
        })
    }
    
    /// Determine if a user can use the camera or not. If a user can use the camera proceed with settings up the capture session. If they cannot, add a message telling the user that they need to authorize camera usage.
    private func setupSessionForUsage() {
        guard self.userSettings.cameraAuthState == .notDetermined else {
            // We've already determined the state, so we can skip setting up the session and simply restart it, then setup the layers.
            self.videoDataOutputQueue.sync { [weak self] in
                self?.startCaptureSession()
                DispatchQueue.main.async {
                    self?.createPreviewLayer()
                    self?.setNativeViewLayerIfNeeded()
                }
            }
            
            return
        }
        
        print("Get camera usage called")
        CameraAuthModel.authorizeCameraForUsage { [weak self] result in
            switch result {
            case .success:
                print("In success section")
                self?.userSettings.cameraAuthState = .authorized
                self?.kickoffCaptureSetup()
                
            case .failure:
                self?.userSettings.cameraAuthState = .denied
                
            }
        }
    }
    
    private func kickoffCaptureSetup() {
        self.videoDataOutputQueue.sync { [weak self] in
            self?.setupAVCapture()
            self?.startCaptureSession()
            DispatchQueue.main.async {
                self?.createPreviewLayer()
                self?.setNativeViewLayerIfNeeded()
            }
        }
    }
    
    /// Setup the video device inputs and capture session.
    private func setupAVCapture() {
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
    
    private func createPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.connection?.isEnabled = true
        self.previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
        self.previewLayer?.connection?.isVideoMirrored = true
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    /// Resets the `VideoFeed`'s `previewLayer` property, and sets it to fit within the `nativeView`'s bounds, and inserts it as a layer.
    public func setPreviewView(to nativeView: NativeView) {
        // Cache the nativeView right away. This may be called before the session is running.
        self.nativeView = nativeView
        
        setNativeViewLayerIfNeeded()
    }
    
    private func setNativeViewLayerIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.userSettings.hideCameraFeed {
                return
            }
            
            // We need the nativeView to have been set to proceed.
            // We also need the previewLayer.
            guard let nativeView = self.nativeView, let previewLayer = self.previewLayer else {
                return
            }
            
            // Set the previewLayer bounds in case the nativeView already has the layer added and just needs to update the frame size.
            self.updatePreviewLayerFrame(to: nativeView.nativeBounds)
            
            if nativeView.nativeLayer?.sublayers == nil || nativeView.nativeLayer?.sublayers?.count == 0 {
                nativeView.nativeLayer?.addSublayer(previewLayer)
            }
        }
    }
    
    /// Remove the previewLayer from any super layer and destroy it.
    private func teardownPreviewLayer() {
        DispatchQueue.main.async { [weak self] in
            self?.nativeView?.nativeLayer?.sublayers?.forEach({
                $0.removeFromSuperlayer()
            })
            
            self?.nativeView?.nativeLayer?.sublayers?.removeAll()
            
            self?.previewLayer?.removeFromSuperlayer()
        }
    }
    
    /// This should be called on its own synchronous queue.
    private func startCaptureSession() {
        self.session.startRunning()
    }
    
    public func updatePreviewLayerFrame(to rect: CGRect) {
        previewLayer?.frame = rect
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
