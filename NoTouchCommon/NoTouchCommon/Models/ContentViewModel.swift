//
//  ContentViewModel.swift
//  HandsOff
//
//  Created by Alexander Mason on 4/19/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreMedia
import Foundation

public class ContentViewModel {
    
    public let feed: VideoFeed
    private let visionModel = VisionModel()
    private let alertVM: AlertViewModel
    
    public init(alertModel: AlertViewModel, userSettings: UserSettings) {
        self.alertVM = alertModel
        self.feed = VideoFeed(userSettings: userSettings)
        feed.delegate = self
        
        visionModel.delegate = self
    }
}

// MARK: - VideoFeedDelegate

extension ContentViewModel: VideoFeedDelegate {
    
    // Here we receive a new sample buffer from the camera feed. Pass this to the Vision model for analysis.
    public func captureOutput(didOutput sampleBuffer: CMSampleBuffer) {
        visionModel.analyzeNewSampleBuffer(sampleBuffer)
    }
}

// MARK: - VisionModelDelegate

extension ContentViewModel: VisionModelDelegate {
    
    // Propogate these errors to SwiftUI. How? a binding mayhaps? A bool that we do a conditional check on in the main body.
    // How do we animate intros/change?
    public func fireAlert() {
        alertVM.touchingDetected()
    }
    
    public func notTouchingDetected() {
        alertVM.notTouchingDetected()
    }
    
    #if DEBUG
    public func faceBoundingBoxUpdated(_ rect: CGRect) {
        // We're not calling this now, but we would only ever use it in debug modes.
        //        DispatchQueue.main.async {
        //            self.trackingView.frame = rect
        //        }
    }
    #endif
}
