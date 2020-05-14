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

class UpdatableMacView: NSView, NativeView {
    var nativeLayer: CALayer?

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

struct VideoLayerView: NSViewRepresentable {
    
    let videoFeed: VideoFeed
    
    func makeNSView(context: Context) -> UpdatableMacView {
        let nativeView = UpdatableMacView()
        return nativeView
    }
    
    func updateNSView(_ nativeView: UpdatableMacView, context: Context) {
        videoFeed.setPreviewView(to: nativeView)
    }
}

