/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Implements the main view controller.
 */

//import UIKit
//import AVFoundation
//import Vision
//
//class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    @IBOutlet weak var previewView: UIView!
//    
////    private var captureConnection: AVCaptureConnection?
////
////    private let session = AVCaptureSession()
////
////    private var previewLayer: AVCaptureVideoPreviewLayer?
////    private let videoDataOutput = AVCaptureVideoDataOutput()
////
////    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
////
////    var alertVM = AlertViewModel()
////
////    private var currentDeviceInput: AVCaptureDeviceInput?
////
////    var devicePosition: AVCaptureDevice.Position? {
////        return currentDeviceInput?.device.position
////    }
//    
//    private var coverView: UIView?
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        // Implement this in the subclass.
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        alertVM.setupAlerts()
//        
//        CameraAuthModel.authorizeCameraForUsage { [weak self] result in
//            switch result {
//            case .success:
//                CameraAuthModel.removeCameraRequirementOverlay()
//                self?.setupAVCapture()
//                
//            case .failure:
//                CameraAuthModel.addCameraRequirementOverlay()
//                
//            }
//        }
//    }
//    
//    func setupAVCapture() {
//        // Select a video device and make an input.
//        let inputDevice: AVCaptureDevice?
//        
//        #if targetEnvironment(macCatalyst)
//        inputDevice = AVCaptureDevice.default(for: .video)
//        #else
//        inputDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                              for: .video,
//                                              position: .front)
//        #endif
//        
//        guard let videoDevice = inputDevice else {
//            //assertionFailure("Couldn't create video device.")
//            return
//        }
//        
//        do {
//            currentDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//        } catch {
//            print("Could not create video device input: \(error).")
//            return
//        }
//        
//        guard let deviceInput = currentDeviceInput else {
//            return
//        }
//        
//        session.beginConfiguration()
//        
//        // The model input size is smaller than 640x480, so better resolution won't help us.
//        session.sessionPreset = .vga640x480
//        
//        // Add a video input.
//        guard session.canAddInput(deviceInput) else {
//            print("Could not add video device input to the session.")
//            session.commitConfiguration()
//            return
//        }
//        session.addInput(deviceInput)
//        
//        if session.canAddOutput(videoDataOutput) {
//            session.addOutput(videoDataOutput)
//            // Add a video data output.
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
//            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
//        } else {
//            print("Could not add video data output to the session.")
//            session.commitConfiguration()
//            return
//        }
//        let captureConnection = videoDataOutput.connection(with: .video)
//        
//        // Always process the frames.
//        captureConnection?.isEnabled = true
//        self.captureConnection = captureConnection
//        
//        session.commitConfiguration()
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        guard let previewLayer = previewLayer else {
//            return
//        }
//        
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        previewLayer.frame = previewView.bounds
//        previewView.layer.insertSublayer(previewLayer, at: 0)
//    }
//    
//    func startCaptureSession() {
//        session.startRunning()
//    }
//    
//    // Clean up capture setup.
//    func teardownAVCapture() {
//        previewLayer?.removeFromSuperlayer()
//        previewLayer = nil
//    }
//    
//    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        //print("The capture output dropped a frame.")
//    }
//    
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
//}
//
//// MARK: - Camera Transitions
//
//extension ViewController {
//    
//    func changeCapturePosition(position: AVCaptureDevice.Position, completion: @escaping (Result<Void, NTError>) -> Void) {
//        guard let currentInput = self.currentDeviceInput else {
//            completion(.failure(.noDeviceInput))
//            return
//        }
//        
//        addCoverView()
//        
//        let delay: TimeInterval = 0.2
//        
//        UIView.animate(withDuration: delay, animations: { [weak self] in
//            self?.coverView?.alpha = 1
//        }) { [weak self] _ in
//            guard let self = self else {
//                return
//            }
//            
//            self.session.removeInput(currentInput)
//            
//            self.currentDeviceInput = nil
//            
//            // create new device
//            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
//                self.removeCoverView()
//                completion(.failure(.inputDeviceCreationFailure))
//                return
//            }
//            
//            do {
//                self.currentDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//            } catch {
//                print("Could not create video device input: \(error).")
//                self.removeCoverView()
//                completion(.failure(.inputDeviceCreationFailure))
//                return
//            }
//            
//            guard let newInput = self.currentDeviceInput else {
//                self.removeCoverView()
//                completion(.failure(.inputDeviceCreationFailure))
//                return
//            }
//            
//            guard self.session.canAddInput(newInput) else {
//                print("Could not add video device input to the session.")
//                self.removeCoverView()
//                self.session.commitConfiguration()
//                completion(.failure(.inputDeviceCreationFailure))
//                return
//            }
//            
//            self.session.addInput(newInput)
//            self.session.commitConfiguration()
//            
//            UIView.animate(withDuration: delay, animations: { [weak self] in
//                self?.coverView?.alpha = 0
//                
//            }) { [weak self] _ in
//                self?.removeCoverView()
//                completion(.success(()))
//                
//            }
//        }
//    }
//    
//    func addCoverView() {
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
//        
//        previewView.addSubview(coverView)
//        
//        NSLayoutConstraint.activate([
//            coverView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
//            coverView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
//            coverView.topAnchor.constraint(equalTo: previewView.topAnchor),
//            coverView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor)
//        ])
//    }
//    
//    func removeCoverView() {
//        coverView?.removeFromSuperview()
//        coverView = nil
//    }
//}
