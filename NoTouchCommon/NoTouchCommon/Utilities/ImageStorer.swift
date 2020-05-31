//
//  ImageStorer.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/14/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation
#if os(OSX)
import AppKit
#elseif os(iOS)
import UIKit
#endif

class ImageStorer {
    
    private static func filePath(forKey key: String) -> URL {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else {
                                                    fatalError("Shouldn't happen")
                                                    
        }
        
        return documentURL.appendingPathComponent(key + ".jpeg")
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static var count = 0
    
    #if os(OSX)
    static func storeNewImage(image: NSImage) {
        #if DEBUG // Only allow this in debug mode, don't want this to sneak into a production build.
        let data = NSBitmapImageRep(data: image.tiffRepresentation!)!.representation(using: .jpeg, properties: [:])!
        let path = filePath(forKey: "\(count)")
        count += 1
        //print("Writing to: \(path)")
        try! data.write(to: path)
        #endif
    }
    #endif
    
    #if os(iOS)
    static func storeNewImage(image: UIImage) {
        #if DEBUG // Only allow this in debug mode, don't want this to sneak into a production build.
        let data = image.jpegData(compressionQuality: 1)!
        let path = filePath(forKey: "\(count)")
        count += 1
        //print("Writing to: \(path)")
        try! data.write(to: path)
        #endif
    }
    #endif
    
    // FIXME: Less important but may be good for testing. Pass in CGImage mayhaps?
    //    static func storeNewImage(image: UIImage) {
    //        if let pngRepresentation = image.pngData() {
    //            if let filePath = filePath(forKey: randomString(length: 12)) {
    //                do  {
//                    print("Trying to write to: \(filePath)")
//
//                    try pngRepresentation.write(to: filePath,
//                                                options: .atomic)
//                } catch let err {
//                    print("Saving file resulted in error: ", err)
//                }
//            }
//
//        } else {
//            print("No PNG data, you fucked up")
//        }
//    }
}
