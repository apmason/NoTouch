import PlaygroundSupport
import Foundation
import Vision
import UIKit

extension UIImage {
    var ciImage: CIImage? {
        guard let data = self.pngData() else { return nil }
        return CIImage(data: data)
    }
    
    // Face Detection with CIDetector
    var faces: [UIImage] {
        guard let ciImage = ciImage else { return [] }
        return (CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])?
            .features(in: ciImage) as? [CIFaceFeature])?
            .map {
                let ciimage = ciImage.cropped(to: $0.bounds)
                return UIImage(ciImage: ciimage)
            }  ?? []
    }
    
    // Face Detection with Vision Framework
    var faces_Vision: [UIImage] {
        guard let ciImage = ciImage else { return [] }

        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        try! VNImageRequestHandler(ciImage: ciImage).perform([faceDetectionRequest])
        
        guard let results = faceDetectionRequest.results as? [VNFaceObservation] else { return [] }
        
        return results.map {
            let translate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
            let bounds = $0.boundingBox.applying(translate)
            let ciimage = ciImage.cropped(to: bounds)
            return UIImage(ciImage: ciimage)
        }
    }
}

let fileManager = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

func writeImageToFile(_ image: UIImage) {
    // Use Vision because that's how we're detecting things.
    for face in image.faces_Vision {
        // create as jpeg, write
        guard let data = face.jpegData(compressionQuality: 1) else {
            print("This is fucked up")
            break
        }
        
        do {
            try data.write(to: fileManager.appendingPathComponent("Training")
                .appendingPathComponent("Touching")
                .appendingPathComponent("\(randomName()).jpeg"))
        } catch {
            print("Error writing: \(error.localizedDescription)")
        }
    }
}

func randomName() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<16).map{ _ in letters.randomElement()! })
}

// name it something random?

let jpegPaths = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: "Touching")

for jpegPath in jpegPaths {
    let url = URL(fileURLWithPath: jpegPath)
    let data = try! Data(contentsOf: url)
    if let image = UIImage(data: data) {
        writeImageToFile(image)
    }
}

//print("JPEGs count is \(jpegs.count)")

// Get an image from URL
//let file = Bundle.main.path(forResource: "Touching/1AA012AA-8A63-4740-A8E9-7286EABEFB91", ofType: "jpeg")!
//print("Image file is: \(file)")



