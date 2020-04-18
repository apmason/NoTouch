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
    
    private var feed: VideoFeed?
    private let visionModel = VisionModel()
    private let alertVM = AlertViewModel()
    private let trackingView = NSView()
    private var nativeView: UpdatableMacView?
    
    func makeNSView(context: Context) -> NSView {
        nativeView = UpdatableMacView()
        feed = VideoFeed(previewView: nativeView!)
        feed?.delegate = self
        feed?.startup()
        
        trackingView.frame = .zero
        trackingView.wantsLayer = true
        trackingView.layer?.backgroundColor = CGColor.black.copy(alpha: 0.4)
        nativeView?.addSubview(trackingView)
        
        visionModel.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillResize(_:)), name: .windowWillResize, object: nil)
        
        return nativeView!
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // FIXME what usually gets called here? I think we'd update the bounds of everything here.
        //print(nsView.bounds)
        //feed?.updatePreviewLayerFrame(to: nsView.bounds)
    }
    
    @objc func windowWillResize(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: CGFloat],
            let height = userInfo["height"],
            let width = userInfo["width"]
            else {
                return
        }
        
        let newRect = CGRect(x: 0, y: 0, width: width, height: height)
        feed?.updatePreviewLayerFrame(to: newRect)
    }
}

// MARK: - VideoFeedDelegate

extension VideoLayerView: VideoFeedDelegate {

    // Here we receive a new sample buffer from the camera feed. Pass this to the Vision model for analysis.
    func captureOutput(didOutput sampleBuffer: CMSampleBuffer) {
        visionModel.analyzeNewSampleBuffer(sampleBuffer)
    }
}

// MARK: - VisionModelDelegate

extension VideoLayerView: VisionModelDelegate {
    
    // Propogate these errors to SwiftUI. How? a binding mayhaps? A bool that we do a conditional check on in the main body.
    // How do we animate intros/change?
    func fireAlert() {
        alertVM.touchingDetected()
    }
    
    func notTouchingDetected() {
        alertVM.notTouchingDetected()
    }
    
    #if DEBUG
    func faceBoundingBoxUpdated(_ rect: CGRect) {
        // We're not calling this now, but we would only ever use it in debug modes.
//        DispatchQueue.main.async {
//            self.trackingView.frame = rect
//        }
    }
    #endif
}
