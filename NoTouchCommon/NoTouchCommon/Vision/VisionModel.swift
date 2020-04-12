//
//  VisionModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AVFoundation
import Foundation
import CoreImage
import Vision
import VideoToolbox

public protocol VisionModelDelegate: class {
    func fireAlert()
    func notTouchingDetected()
}

public class VisionModel {
    // Vision parts
    private var analysisRequests = [VNRequest]()
    
    private var previousPixelBuffer: CVPixelBuffer?
    
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedPixelBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification and barcode requests
    private let visionQueue = DispatchQueue(label: "com.NoTouch.serialVisionQueue")
    
    private var touchingRequest: VNCoreMLRequest?
    private var faceBoundingRequest: VNDetectFaceRectanglesRequest!
    
    private let ciContext = CIContext()
    
    public weak var delegate: VisionModelDelegate?
    
    // FIXME: Is this proper form?
    public init() {
        setupVision()
    }
    
    /// - Tag: SetupVisionRequest
    @discardableResult
    private func setupVision() -> NoTouchError? {
        let modelURL: URL
        // TODO: This should be the YOLO model.
        if let updatedURL = Bundle(for: type(of: self)).url(forResource: "NoTouch_YOLO_2", withExtension: "mlmodelc") {
            modelURL = updatedURL
        } else {
            assertionFailure("A model wasn't able to be retrieved")
            return NoTouchError.missingModelFile // TODO: Add logging.
        }
        
        // First try with the updated URL, if anything is there continue
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            
            guard let touchingRequest = createTouchingRequest(mlModel: mlModel) else {
                return NoTouchError.visionRequestFailure
            }
            
            self.touchingRequest = touchingRequest
            self.faceBoundingRequest = createFaceBoundingRequest()
            
            // analysisRequests will always only contain the Face Request
            self.analysisRequests.append(faceBoundingRequest)
            return nil
        } catch {
            print("Error creating MLModel: \(error.localizedDescription)")
            return NoTouchError.modelCreationFailure(error)
        }
    }
    
    private func createFaceBoundingRequest() -> VNDetectFaceRectanglesRequest {
        // Release the pixel buffer when done, allowing the next buffer to be processed.
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self, let pixelBuffer = self.currentlyAnalyzedPixelBuffer else {
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                let boundingBox = results.first?.boundingBox else {
                    // As a fallback run with the whole pixel buffer, rather than just focusing on the face.
                    let touchRequest = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: Orienter.currentCGOrientation())
                    self.visionQueue.async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        // TODO: Tell the user we can't find their face so they update their position. (If we can't find their face then should we stop analysis? Will need to test, maybe if they do it a certain number of times, how much does it degrade the performance?)
                        
                        // TODO: Also do as we do below with `modelUpdater.addImage`, we should not perform a touching request here.
                        
                        do {
                            // Release the pixel buffer when done, allowing the next buffer to be processed.
                            defer { self.currentlyAnalyzedPixelBuffer = nil }
                            guard let touchingRequest = self.touchingRequest else {
                                return
                            }
                            
                            try touchRequest.perform([touchingRequest])
                        } catch {
                            print("Error: Vision request failed with error \"\(error)\"")
                        }
                    }
                    return
            }
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            let translate = CGAffineTransform.identity.scaledBy(x: ciImage.extent.width, y: ciImage.extent.height)
            
            let bounds = boundingBox.applying(translate)
            
            // Image is rotated 90 degrees to the left
            let cheekOffset = ciImage.extent.height * 0.025
            let chinOffset: CGFloat = ciImage.extent.width * 0.09
            
            let updatedBounds = CGRect(x: bounds.origin.x - chinOffset,
                                       y: bounds.origin.y - cheekOffset,
                                       width: bounds.width + (chinOffset * 2),
                                       height: bounds.height + (cheekOffset * 2))
            
            let cgImage = self.ciContext.createCGImage(ciImage, from: updatedBounds)
            
            guard let unwrappedCGImage = cgImage else {
                self.currentlyAnalyzedPixelBuffer = nil
                return
            }
            
            // Don't need to analyze the images currently.
            //            let uiImage = UIImage(cgImage: unwrappedCGImage)
            //            ImageStorer.storeNewImage(image: uiImage)
            
            let touchRequest = VNImageRequestHandler(cgImage: unwrappedCGImage, orientation: Orienter.currentCGOrientation())
            self.visionQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                do {
                    defer { self.currentlyAnalyzedPixelBuffer = nil }
                    guard let touchingRequest = self.touchingRequest else {
                        return
                    }
                    
                    try touchRequest.perform([touchingRequest])
                } catch {
                    print("Error: Vision request failed with error \"\(error)\"")
                }
            }
        }
        return request
    }
    
    private func createTouchingRequest(mlModel: MLModel) -> VNCoreMLRequest? {
        do {
            let yoloModel = try VNCoreMLModel(for: mlModel)
            let observationRequest = VNCoreMLRequest(model: yoloModel, completionHandler: { [weak self] (request, error) in
                guard let results = request.results else {
                    return
                }
                
                for observation in results where observation is VNRecognizedObjectObservation {
                    guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                        continue
                    }

                    // Make sure we have at least one item detected.
                    if objectObservation.labels.count > 0 {
                        let bestObservation = objectObservation.labels[0]
                        
                        guard bestObservation.identifier == "hand" else {
                            return
                        }
                        
                        print("Confidence is: \(objectObservation.confidence)")
                        
                        DispatchQueue.main.async { [weak self] in
                            if objectObservation.confidence > 0.23 {
                                self?.delegate?.fireAlert()
                            } else {
                                self?.delegate?.notTouchingDetected()
                            }
                        }
                    }
                }
            })
            
            observationRequest.imageCropAndScaleOption = .scaleFill // @ALEX: Test this with different options, does it work best?
            return observationRequest
            
        } catch let error as NSError {
            print("Model failed to load: \(error).")
            return nil
        }
    }
    
    /// - Tag: AnalyzeImage
    private func findFace() {
        // Most computer vision tasks are not rotation-agnostic, so it is important to pass in the orientation of the image with respect to device.
        guard let pixelBuffer = currentlyAnalyzedPixelBuffer else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                   orientation: Orienter.currentCGOrientation())
        
        visionQueue.async {
            do {
                try requestHandler.perform(self.analysisRequests)
                //print("#Perform find face")
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
}

// MARK: - Handling new sample buffers

extension VisionModel {
    
    public func analyzeNewSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
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
}
