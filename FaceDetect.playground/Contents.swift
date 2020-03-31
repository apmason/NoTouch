import PlaygroundSupport
import Foundation
import Vision
import UIKit

extension UIImage {
    var ciImage: CIImage? {
        guard let data = self.jpegData(compressionQuality: 1) else { return nil }
        return CIImage(data: data)
    }
    
    // Face Detection with Vision Framework
    var faces_Vision: [UIImage] {
        guard let ciImage = ciImage else { return [] }

        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        try! VNImageRequestHandler(ciImage: ciImage).perform([faceDetectionRequest])
        
        guard let results = faceDetectionRequest.results as? [VNFaceObservation] else { return [] }
        
        
        // TODO: Add twenty percent to the height (more chin)
//        let translate = CGAffineTransform.identity.scaledBy(x: ciImage.extent.width, y: ciImage.extent.height) // TODO: Test extending the face detection area, maybe get more chin touches?
        
        // translated by? move it a little further away?
        //let shiftUp = CGAffineTransform.identity.translatedBy(x: -extraRoom / 2, y: 0)
        //let bounds = boundingBox.applying(translate).applying(shiftUp)
        
        // Add other translatiion
        //boundingBox.applying(.translatedBy(x: -twentyPercent * 3, y: 0))
                
        return results.map {
            //let extraRoom: CGFloat = ciImage.extent.height * 0.3
            let translate = CGAffineTransform.identity.scaledBy(x: ciImage.extent.width, y: ciImage.extent.height)
            let bounds = $0.boundingBox.applying(translate)
            print("Initial bounds: \(bounds)")
            
            let chinOffset = ciImage.extent.height * 0.1
            let widthOffset: CGFloat = ciImage.extent.width * 0.025
            
            // NOTE: x and y will be flipped when bringing into NoTouch
            let finalBounds = CGRect(x: bounds.origin.x - widthOffset,
                                     y: bounds.origin.y - chinOffset,
                                     width: bounds.width + (widthOffset * 2),
                                     height: bounds.height + (chinOffset * 2))
            
            let cgImage = CIContext().createCGImage(ciImage, from: finalBounds)!
            
            return UIImage(cgImage: cgImage)
        }
    }
}

// Get an image from URL
let fileString = Bundle.main.path(forResource: "Touching/277641F6-E5EE-466C-9AF6-B321617B8C99", ofType: "jpeg")!
let fileURL = URL(fileURLWithPath: fileString)
let data = try! Data(contentsOf: fileURL)
let image = UIImage(data: data)!

let face = image.faces_Vision.first!
print(face)
