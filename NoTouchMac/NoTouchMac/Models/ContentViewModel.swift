//
//  ContentViewModel.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/19/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AppKit
import CoreMedia
import NoTouchCommon
import Foundation

class ContentViewModel {
    
    let feed: VideoFeed = VideoFeed(userSettings: AppDelegate.userSettings)
    private let feedResizer: FeedResizer
    private let visionModel = VisionModel()
    private let alertVM = AlertViewModel(userSettings: AppDelegate.userSettings)
    
    init() {
        feedResizer = FeedResizer(feed)
        feed.delegate = self
        feed.startup()
        
        visionModel.delegate = self
    }
    
    public func setPreviewView(to nativeView: NSView) {
        feed.setPreviewView(to: nativeView)
    }
}

// MARK: - VideoFeedDelegate

extension ContentViewModel: VideoFeedDelegate {
    
    // Here we receive a new sample buffer from the camera feed. Pass this to the Vision model for analysis.
    func captureOutput(didOutput sampleBuffer: CMSampleBuffer) {
        visionModel.analyzeNewSampleBuffer(sampleBuffer)
    }
}

// MARK: - VisionModelDelegate

extension ContentViewModel: VisionModelDelegate {
    
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
