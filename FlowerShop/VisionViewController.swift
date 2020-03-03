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
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    
    // Registration history
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification and barcode requests
    private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.FlowerShop.serialVisionQueue")
    
    @IBOutlet var coverageView: UIView!
    
    @IBOutlet var flashingView: UIView!
    
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
        guard let modelURL = Bundle.main.url(forResource: "Faces", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file is missing."])
        }
        guard let objectRecognition = createClassificationRequest(modelURL: modelURL) else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
        }
        self.analysisRequests.append(objectRecognition)
        return error
    }
    
    private func createClassificationRequest(modelURL: URL) -> VNCoreMLRequest? {
        do {
            let objectClassifier = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let classificationRequest = VNCoreMLRequest(model: objectClassifier, completionHandler: { [weak self] (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    print("\(results.first!.identifier) : \(results.first!.confidence)")
                    if results.first!.identifier == "Touching" && results.first!.confidence > 0.90 {
                        print("WINNER!!!")
                        self?.alertVM.fireAlert()
                    }
                }
            })
            return classificationRequest
            
        } catch let error as NSError {
            print("Model failed to load: \(error).")
            return nil
        }
    }
    
    /// - Tag: AnalyzeImage
    private func analyzeCurrentImage() {
        // Most computer vision tasks are not rotation-agnostic, so it is important to pass in the orientation of the image with respect to device.
        let orientation = exifOrientationFromDeviceOrientation()
        
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
    fileprivate func resetTranspositionHistory() {
        transpositionHistoryPoints.removeAll()
    }
    
    fileprivate func recordTransposition(_ point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }
    /// - Tag: CheckSceneStability
    fileprivate func sceneStabilityAchieved() -> Bool {
        // Determine if we have enough evidence of stability.
        if transpositionHistoryPoints.count == maximumHistoryLength {
            // Calculate the moving average.
            var movingAverage: CGPoint = CGPoint.zero
            for currentPoint in transpositionHistoryPoints {
                movingAverage.x += currentPoint.x
                movingAverage.y += currentPoint.y
            }
            let distance = abs(movingAverage.x) + abs(movingAverage.y)
            if distance < 20 {
                return true
            }
        }
        return false
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard previousPixelBuffer != nil else {
            previousPixelBuffer = pixelBuffer
            self.resetTranspositionHistory()
            return
        }
        
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
        do {
            try sequenceRequestHandler.perform([ registrationRequest ], on: previousPixelBuffer!)
        } catch let error as NSError {
            print("Failed to process request: \(error.localizedDescription).")
            return
        }
        
        previousPixelBuffer = pixelBuffer
        
        if let results = registrationRequest.results {
            if let alignmentObservation = results.first as? VNImageTranslationAlignmentObservation {
                let alignmentTransform = alignmentObservation.alignmentTransform
                self.recordTransposition(CGPoint(x: alignmentTransform.tx, y: alignmentTransform.ty))
            }
        }
        if self.sceneStabilityAchieved() {
            showDetectionOverlay(true)
            if currentlyAnalyzedPixelBuffer == nil {
                // Retain the image buffer for Vision processing.
                currentlyAnalyzedPixelBuffer = pixelBuffer
                analyzeCurrentImage()
            }
        } else {
            showDetectionOverlay(false)
        }
    }
    
    private func showDetectionOverlay(_ visible: Bool) {
        
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
    
    @IBAction func flipSound(_ sender: Any) {
        
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Show footage")
            coverageView.isHidden = true
            
        } else {
            print("Cover footage")
            coverageView.isHidden = false
            
        }
    }
}


extension VisionViewController: AlertObserver {
    
    func alertDidFire(withTimeoutPeriod timeoutPeriod: TimeInterval) {
        flashingView.alpha = 0
        flashingView.isHidden = false
        
        UIView.animateKeyframes(withDuration: timeoutPeriod, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.flashingView.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.flashingView.alpha = 0
            }
            
        }) { _ in
            self.flashingView.alpha = 0
            self.flashingView.isHidden = true
        }
    }
}
