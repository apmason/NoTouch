//
//  VideoLayerView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AppKit
import CoreMedia
import Foundation
import NoTouchCommon
import SwiftUI

class UpdatableMacView: NSView, NativewView {    
    
    var nativeLayer: CALayer? {
        return self.layer
    }

    var nativeFrame: CGRect {
        return self.frame
    }

    var nativeBounds: CGRect {
        return self.bounds
    }
}

final class VideoLayerView: NSViewRepresentable {
    
    private var nativeView: UpdatableMacView?
    
    init(inputtingTo videoFeed: VideoFeed) {
        videoFeed.setPreviewView(to: nativeView!)
    }
    
    func makeNSView(context: Context) -> NSView {
        print("Make ns view called")
        nativeView = UpdatableMacView()
        
        return nativeView!
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

