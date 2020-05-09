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

final class VideoLayerView: NSViewRepresentable {
    
    let alertModel: AlertViewModel
    
    init(alertModel: AlertViewModel) {
        self.alertModel = alertModel
    }
    
    func makeNSView(context: Context) -> UpdatableMacView {
        let nativeView = UpdatableMacView()
        return nativeView
    }
    
    func updateNSView(_ nativeView: UpdatableMacView, context: Context) {
        // Update our video layer.
        context.coordinator.contentViewModel.setPreviewView(to: nativeView)
    }
    
    class Coordinator: NSObject {
        var parent: VideoLayerView
        let contentViewModel: ContentViewModel

        init(_ videoLayerView: VideoLayerView, alertModel: AlertViewModel) {
            self.parent = videoLayerView
            self.contentViewModel = ContentViewModel(alertModel: alertModel)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, alertModel: alertModel)
    }
}

