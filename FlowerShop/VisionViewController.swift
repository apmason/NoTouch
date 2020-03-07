/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the Vision view controller.
*/

import UIKit
import AVFoundation
import Vision

class VisionViewController: ViewController {
        
    // Vision parts
    private var analysisRequests = [VNRequest]()
    //private let sequenceRequestHandler = VNSequenceRequestHandler()
    
    // Registration history
//    private let maximumHistoryLength = 15
//    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification and barcode requests
    private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.FlowerShop.serialVisionQueue")
    
    @IBOutlet var coverageView: UIView!
    @IBOutlet var flashingView: UIView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var announcementLabel: UILabel!
    
    private var coreMLRequest: VNCoreMLRequest!
    private var faceRequest: VNDetectFaceRectanglesRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertVM.addObserver(self)
    }
    
    /// - Tag: SetupVisionRequest
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts.
        let error: NSError! = nil
        
        // Setup a classification request.
        guard let modelURL = Bundle.main.url(forResource: "adam-official-6", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file is missing."])
        }
        
        guard let objectRecognition = createClassificationRequest(modelURL: modelURL) else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
        }
        
        self.coreMLRequest = objectRecognition
        self.faceRequest = createFaceRequest()
        
        // Analysis requests will always call for the Face Request
        self.analysisRequests.append(faceRequest)
        return error
    }
    
    private func createFaceRequest() -> VNDetectFaceRectanglesRequest {
        //VNDetectFaceRectanglesRequest
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNDetectedObjectObservation], let boundingBox = results.first?.boundingBox, let pixelBuffer = self.currentlyAnalyzedPixelBuffer else {
                print("Face detect failed")
                // As a fallback run with the whole pixel buffer
                let touchRequest = VNImageRequestHandler(cvPixelBuffer: self.currentlyAnalyzedPixelBuffer!, orientation: self.exifOrientationFromDeviceOrientation())
                self.visionQueue.async {
                    do {
                        // Release the pixel buffer when done, allowing the next buffer to be processed.
                        try touchRequest.perform([self.coreMLRequest])
                    } catch {
                        print("Error: Vision request failed with error \"\(error)\"")
                    }
                }
                return
            }
            
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            ciImage.cropped(to: boundingBox)
            
            let touchRequest = VNImageRequestHandler(ciImage: ciImage, orientation: self.exifOrientationFromDeviceOrientation(), options: [:])
            self.visionQueue.async {
                do {
                    // Release the pixel buffer when done, allowing the next buffer to be processed.
                    try touchRequest.perform([self.coreMLRequest])
                } catch {
                    print("Error: Vision request failed with error \"\(error)\"")
                }
            }
            // Run new request with this new data.
        }
        
        return request
    }
    
    private func createClassificationRequest(modelURL: URL) -> VNCoreMLRequest? {
        do {
            let objectClassifier = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let classificationRequest = VNCoreMLRequest(model: objectClassifier, completionHandler: { [weak self] (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    //print("Result count is \(results.count)")
//                    for result in results {
//                        print("Result identifier is: \(result.identifier), confidence is \(result.confidence)")
//                    }
                    if results.first!.identifier == "Touching" {
                        print("Confidence is: \(results.first!.confidence)")
                    }
                
                    
//                    print("\(results.first!.identifier) : \(results.first!.confidence)")
                    if results.first!.identifier == "Touching" && results.first!.confidence > 12 {
                        //print("WINNER!!!")
                        DispatchQueue.main.async { [weak self] in
                            self?.alertVM.fireAlert()
                        }
                    }
                }
            })
            classificationRequest.imageCropAndScaleOption = .centerCrop // @ALEX: Test this with different options, does it work best?
            return classificationRequest
            
        } catch let error as NSError {
            print("Model failed to load: \(error).")
            return nil
        }
    }
    
    /// - Tag: AnalyzeImage
    private func findFace() {
        // Most computer vision tasks are not rotation-agnostic, so it is important to pass in the orientation of the image with respect to device.
        let orientation = exifOrientationFromDeviceOrientation()
        
        //let newPic = VNImageRequestHandler(
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalyzedPixelBuffer!, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentlyAnalyzedPixelBuffer = nil }
                try requestHandler.perform(self.analysisRequests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard previousPixelBuffer != nil else {
            previousPixelBuffer = pixelBuffer
            return
        }
        
        previousPixelBuffer = pixelBuffer
        
        if currentlyAnalyzedPixelBuffer == nil {
            // Retain the image buffer for Vision processing.
            currentlyAnalyzedPixelBuffer = pixelBuffer
            findFace()
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    @IBAction func flipCamera(_ sender: Any) {
//        switch captureDevicePosition {
//        case .front:
//            captureDevicePosition = .back
//
//        case .back:
//            captureDevicePosition = .front
//
//        case .unspecified:
//            print("Unspecified device position set")
//
//        }
        
        setupAVCapture()
    }
    
    @IBAction func muteUnmuteSound(_ sender: Any) {
        if alertVM.audioIsMuted {
            alertVM.audioIsMuted = false
            
            guard let image = UIImage(systemName: "speaker") else {
                return
            }
            
            // set image
            audioButton.setImage(image, for: .normal)
        } else {
            alertVM.audioIsMuted = true
            guard let image = UIImage(systemName: "speaker.slash") else {
                return
            }
            
            audioButton.setImage(image, for: .normal)
        }
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            announcementLabel.isHidden = true
            coverageView.isHidden = true
            
        } else {
            coverageView.isHidden = false // animate this?
            
            announcementLabel.alpha = 0
            announcementLabel.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.announcementLabel.alpha = 1
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIView.animate(withDuration: 0.8, animations: {
                        self.announcementLabel.alpha = 0
                    }) { _ in
                        self.announcementLabel.isHidden = true
                    }
                }
            }
        }
    }
}


extension VisionViewController: AlertObserver {
    
    func startAlerting() {
        flashingView.alpha = 0
        flashingView.isHidden = false
        
        UIView.animate(withDuration: 0.1) {
            self.flashingView.alpha = 0.4
        }
    }
    
    func stopAlerting() {
        UIView.animate(withDuration: 0.1, animations: {
            self.flashingView.alpha = 0
        }) { _ in
            self.flashingView.alpha = 0
            self.flashingView.isHidden = true
        }
    }
}
