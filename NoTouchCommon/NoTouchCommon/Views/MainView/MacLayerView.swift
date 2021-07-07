//
//  VideoLayerView.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

#if os(OSX)
import AppKit
import CoreMedia
import Foundation
import SwiftUI

class UpdatableMacView: NSView, NativeView {
    
    /// This layer should be set directly.
    var nativeLayer: CALayer? {
        if !self.wantsLayer {
            self.wantsLayer = true
        }
        
        return self.layer
    }

    var nativeFrame: CGRect {
        return self.frame
    }

    var nativeBounds: CGRect {
        return self.bounds
    }
    
    func setToWantLayer(_ wantsLayer: Bool) {
        self.wantsLayer = wantsLayer
    }
}

struct MacLayerView: NSViewRepresentable {
    
    let videoFeed: VideoFeed
    
    func makeNSView(context: Context) -> UpdatableMacView {
        let nativeView = UpdatableMacView()
        nativeView.wantsLayer = true
        return nativeView
    }
    
    func updateNSView(_ nativeView: UpdatableMacView, context: Context) {
        videoFeed.setPreviewView(to: nativeView)
    }
}
#endif
