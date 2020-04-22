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
    var nativeLayer: CALayer?

    var nativeFrame: CGRect {
        return self.frame
    }

    var nativeBounds: CGRect {
        return self.bounds
    }
    
//    init() {
//        super.init(frame: .zero)
//        self.nativeLayer = layer
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.nativeLayer = layer
//    }
}

final class VideoLayerView: NSViewRepresentable {
    
//    private let nativeView = UpdatableMacView()
//    private let model: ContentViewModel
////    init(inputtingTo videoFeed: VideoFeed) {
////        videoFeed.setPreviewView(to: nativeView!)
////    }
//    init(model: ContentViewModel) {
//        print("Video layer view init")
//        self.model = model
//    }
    
    func makeNSView(context: Context) -> UpdatableMacView {
        print("Make ns view called")
        let nativeView = UpdatableMacView()
        return nativeView
    }
    
    func updateNSView(_ nsView: UpdatableMacView, context: Context) {
        //context.coordinator.contentViewModel.setPreviewView(to: nativeView!)
        //model.setPreviewView(to: nativeView)
        if nsView.wantsLayer {
            print("Wants update layer!!")
        } else {
            print("No update layer!!")
        }
        
        context.coordinator.contentViewModel.setPreviewView(to: nsView, withRect: nsView.bounds)
    }
    
    class Coordinator: NSObject {
        var parent: VideoLayerView
        let contentViewModel = ContentViewModel()

        init(_ videoLayerView: VideoLayerView) {
            self.parent = videoLayerView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

