//
//  VisionModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/10/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

#if os(OSX)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import AVFoundation
import Foundation
import CoreImage
import Vision
import VideoToolbox

public protocol VisionModelDelegate: class {
    func fireAlert()
    func notTouchingDetected()
    #if DEBUG
    func faceBoundingBoxUpdated(_ rect: CGRect)
    #endif
}

public class VisionModel {
    // Vision parts
    private var analysisRequests = [VNRequest]()
        
    // The current pixel buffer undergoing analysis. Run requests in a serial fashion, one after another.
    private var currentlyAnalyzedCIImage: CIImage?
    
    // Queue for dispatching vision classification and barcode requests
    private let visionQueue = DispatchQueue(label: "com.NoTouch.serialVisionQueue")
    
    private var touchingRequest: VNCoreMLRequest?
    private var faceBoundingRequest: VNDetectFaceRectanglesRequest!
    
    private let ciContext = CIContext()
    
    public weak var delegate: VisionModelDelegate?
    
    // Throttling only available on macOS.
    #if os(OSX)
    /// The number of frames that have come through without being processed
    private var frameCount = 0
    
    /// The threshold of frames that must come through before one is processed.
    private var threshold = 4
    #endif
    
    public init() {
        setupVision()
    }
    
    /// - Tag: SetupVisionRequest
    @discardableResult
    private func setupVision() -> NoTouchError? {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ohyeah2", withExtension: "mlmodelc") else {
            assertionFailure("A model wasn't able to be retrieved")
            return NoTouchError.missingModelFile
        }
        
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
        // Make sure to release the pixel buffer when done, allowing the next buffer to be processed.
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self, let ciImage = self.currentlyAnalyzedCIImage else {
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                let boundingBox = results.first?.boundingBox else {
                    // If a face can't be found don't analyze. Release the pixel buffer so we can grab a new buffer.
                    self.currentlyAnalyzedCIImage = nil
                    return
            }
            
            let bounds = VNImageRectForNormalizedRect(boundingBox, Int(ciImage.extent.width), Int(ciImage.extent.height))
            
            let chinOffset = ciImage.extent.height * 0.1
            let widthOffset: CGFloat = ciImage.extent.width * 0.1
            
            let updatedBounds = CGRect(x: bounds.origin.x - widthOffset,
                                       y: bounds.origin.y - chinOffset,
                                       width: bounds.width + (widthOffset * 2),
                                       height: bounds.height + (chinOffset * 2))
            
            #if DEBUG
            self.delegate?.faceBoundingBoxUpdated(updatedBounds)
            #endif
            
            let cgImage = self.ciContext.createCGImage(ciImage, from: updatedBounds)
            
            guard let unwrappedCGImage = cgImage else { // Things broke for some reason, just exit.
                self.currentlyAnalyzedCIImage = nil
                return
            }
            
            // Don't need to analyze the images currently.
//            #if os(OSX)
//            let image = NSImage(cgImage: unwrappedCGImage, size: NSSize(width: unwrappedCGImage.width, height: unwrappedCGImage.height))
//            ImageStorer.storeNewImage(image: image)
//            #elseif os(iOS)
//            let image = UIImage(cgImage: unwrappedCGImage)
//            ImageStorer.storeNewImage(image: image)
//            #endif
            
            #if os(iOS)
            // If using the front facing camera this will always be in portrait mode.
            let touchRequest = VNImageRequestHandler(cgImage: unwrappedCGImage,
                                                     orientation: .up) // This is the format of the camera itself. A back facing camera on iOS is mirrored, front facing is not. In portrait mode the image is rotated to the left (for CGImage, not sure if this is true when in other orientations).
            #else
            let touchRequest = VNImageRequestHandler(cgImage: unwrappedCGImage,
                                                     orientation: .up)
            #endif
            
            self.visionQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                do {
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
                //print("detect: \(Date().timeIntervalSince1970)")
                self?.currentlyAnalyzedCIImage = nil
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                        return
                }
                
                var score: Double = 0
                
                // loop through all results
                for result in results {
                    if result.confidence > 0.8 {
                        score += 3
                    } else if result.confidence < 0.6 {
                        score += 1
                    } else {
                        // Using 0.8 - 0.6 = 0.2 as a constant here for speed.
                        // Calculate the distance between 0.6 and 0.8 that the confidence is.
                        let percentBetween = (result.confidence - 0.6) / 0.2
                        score += Double((percentBetween * 2) + 1)
                    }
                }
                
                var activate = false
                
                if score > 4.5 {
                    activate = true
                }
                
                DispatchQueue.main.async { [weak self] in
                    if activate {
                        self?.delegate?.fireAlert()
                    } else {
                        self?.delegate?.notTouchingDetected()
                    }
                }
            })
            
            observationRequest.imageCropAndScaleOption = .scaleFill
            return observationRequest
            
        } catch let error as NSError {
            print("Model failed to load: \(error).")
            return nil
        }
    }
    
    /// - Tag: AnalyzeImage
    private func findFace() {
        // Most computer vision tasks are not rotation-agnostic, so it is important to pass in the orientation of the image with respect to device.
        guard let ciImage = currentlyAnalyzedCIImage else {
            assertionFailure("No pixelbuffer, this shouldn't happen")
            return
        }
        
        let requestHandler = VNImageRequestHandler(ciImage: ciImage,
                                                   orientation: .up)
        
        visionQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                try requestHandler.perform(self.analysisRequests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
}

// MARK: - Handling new sample buffers

extension VisionModel {
    
    public func analyzeNewSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if currentlyAnalyzedCIImage == nil {
            #if os(OSX)
            frameCount += 1
            if frameCount > threshold {
                frameCount = 0
            } else {
                return
            }
            #endif
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            self.currentlyAnalyzedCIImage = CIImage(cvPixelBuffer: pixelBuffer)
            guard let ciImage = currentlyAnalyzedCIImage else {
                return
            }
                        
            #if os(iOS)
            /**
             In portrait mode the image is rotated 90 degrees to the left, this is the default when using the front facing camera on iOS.
             If we are not currently in portrait mode, transform the image so we are. Then this is the only transformation we need to do.
             */
            if UIDevice.current.orientation == .landscapeLeft {
                let beforeWidth = ciImage.extent.width
                self.currentlyAnalyzedCIImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))).transformed(by: CGAffineTransform(translationX: 0, y: beforeWidth))
            } else if UIDevice.current.orientation == .landscapeRight {
                let beforeHeight = ciImage.extent.height
                self.currentlyAnalyzedCIImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))).transformed(by: CGAffineTransform(translationX: beforeHeight, y: 0))
            }            
            #endif
            
            findFace()
        }
    }
}
