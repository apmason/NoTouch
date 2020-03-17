/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the Vision view controller.
*/

import AVFoundation
import UIKit
import VideoToolbox
import Vision

class VisionViewController: ViewController {
        
    // Vision parts
    private var analysisRequests = [VNRequest]()

    private var previousPixelBuffer: CVPixelBuffer?
    
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification and barcode requests
    private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.NoTouch.serialVisionQueue")
    
    @IBOutlet var coverageView: UIView!
    @IBOutlet var flashingView: UIView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var announcementLabel: UILabel!
    
    private var coreMLRequest: VNCoreMLRequest!
    private var faceRequest: VNDetectFaceRectanglesRequest!
    
    private let ciContext = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertVM.addObserver(self)
    }
    
    /// - Tag: SetupVisionRequest
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts.
        
        // Setup a classification request.
        guard let modelURL = Bundle.main.url(forResource: "cropped-official", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file is missing."])
        }
        
        guard let objectRecognition = createClassificationRequest(modelURL: modelURL) else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
        }
        
        self.coreMLRequest = objectRecognition
        self.faceRequest = createFaceRequest()
        
        // Analysis requests will always call for the Face Request
        self.analysisRequests.append(faceRequest)
        return nil
    }
    
    private func createFaceRequest() -> VNDetectFaceRectanglesRequest {
        // Release the pixel buffer when done, allowing the next buffer to be processed.
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self, let pixelBuffer = self.currentlyAnalyzedPixelBuffer else {
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                let boundingBox = results.first?.boundingBox else {
                //print("#Face detect failed")
                
                // As a fallback run with the whole pixel buffer, rather than just focusing on the face.
                let touchRequest = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: self.exifOrientationFromDeviceOrientation())
                self.visionQueue.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    do {
                        // Release the pixel buffer when done, allowing the next buffer to be processed.
                        defer { self.currentlyAnalyzedPixelBuffer = nil }
                        try touchRequest.perform([self.coreMLRequest])
                    } catch {
                        print("Error: Vision request failed with error \"\(error)\"")
                    }
                    }
                    return
            }
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            // Add some height for chin touching
            let translate = CGAffineTransform.identity.scaledBy(x: ciImage.extent.width, y: ciImage.extent.height + 30)
            let bounds = boundingBox.applying(translate)
            
            let cgImage = self.ciContext.createCGImage(ciImage, from: bounds)
            
            guard let unwrappedCGImage = cgImage else {
                self.currentlyAnalyzedPixelBuffer = nil
                return
            }
            
            // Don't need to analyze the images currently.
            //                let uiImage = UIImage(cgImage: unwrappedCGImage)
            //                ImageStorer.storeNewImage(image: uiImage)
            
            let touchRequest = VNImageRequestHandler(cgImage: unwrappedCGImage, orientation: self.exifOrientationFromDeviceOrientation())
            self.visionQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                do {
                    defer { self.currentlyAnalyzedPixelBuffer = nil }
                    try touchRequest.perform([self.coreMLRequest])
                } catch {
                    print("Error: Vision request failed with error \"\(error)\"")
                }
            }
        }
        return request
    }
    
    private func createClassificationRequest(modelURL: URL) -> VNCoreMLRequest? {
        do {
            let objectClassifier = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let classificationRequest = VNCoreMLRequest(model: objectClassifier, completionHandler: { [weak self] (request, error) in
                if let results = request.results as? [VNClassificationObservation],
                    let first = results.first {
                    if first.identifier == "Touching" {
                        print("Confidence is: \(first.confidence)")
                    }
                
                    if first.identifier == "Touching" && first.confidence > 10 {
                        print("Qualified")
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
        
        guard let pixelBuffer = currentlyAnalyzedPixelBuffer else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation)
        //print("#Kick off find face")
        visionQueue.async {
            do {
                try requestHandler.perform(self.analysisRequests)
                //print("#Perform find face")
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
    
    // MARK: - IBActions
    
    @IBAction func flipCamera(_ sender: Any) {
        guard let oldPosition = devicePosition else {
            return
        }
        
        let newPosition: AVCaptureDevice.Position
        
        switch oldPosition {
        case .front:
            // set to back
            newPosition = .back
            
        case .back:
            // set to front
            newPosition = .front
            
        default:
            newPosition = .front
            break
        }
        
        changeCapturePosition(position: newPosition) { result in
            switch result {
            case .success:
                // Do nothing
                break
                
            case .failure(let error):
                // TODO: present error and localized description
                print("Error changing capture position: \(error.localizedDescription)")
                
            }
        }
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
        }) { success in
            if success {
                self.flashingView.alpha = 0
                self.flashingView.isHidden = true
            } else {
                print("No success")
            }
        }
    }
}
