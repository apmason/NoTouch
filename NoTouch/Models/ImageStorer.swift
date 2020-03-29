//
//  ImageStorer.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/14/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation
import UIKit

class ImageStorer {
    
    private static func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func storeNewImage(image: UIImage) {
        if let pngRepresentation = image.pngData() {
            if let filePath = filePath(forKey: randomString(length: 12)) {
                do  {
                    print("Trying to write to: \(filePath)")
                    
                    try pngRepresentation.write(to: filePath,
                                                options: .atomic)
                } catch let err {
                    print("Saving file resulted in error: ", err)
                }
            }
            
        } else {
            print("No PNG data, you fucked up")
        }
    }
}
