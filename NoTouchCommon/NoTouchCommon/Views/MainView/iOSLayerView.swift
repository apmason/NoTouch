//
//  iOSLayerView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/24/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

#if os(iOS)
import UIKit
import SwiftUI

class UpdatableIOSView: UIView, NativeView {
    
    var nativeLayer: CALayer? {
        return self.layer
    }
    
    var nativeFrame: CGRect {
        return self.frame
    }
    
    var nativeBounds: CGRect {
        return self.bounds
    }
    
    func setToWantLayer(_ wantsLayer: Bool) {}
}

struct iOSLayerView: UIViewRepresentable {
    
    let videoFeed: VideoFeed
    
    func makeUIView(context: Context) -> UpdatableIOSView {
        let nativeView = UpdatableIOSView()
        return nativeView
    }
    
    func updateUIView(_ uiView: UpdatableIOSView, context: Context) {
        videoFeed.setPreviewView(to: uiView)
    }
}
#endif
