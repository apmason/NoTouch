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
}

final class VideoLayerView: NSViewRepresentable {
    
    let alertModel: AlertViewModel
    
    init(alertModel: AlertViewModel) {
        self.alertModel = alertModel
    }
    
    func makeNSView(context: Context) -> UpdatableMacView {
        print("Make ns view called")
        let nativeView = UpdatableMacView()
        return nativeView
    }
    
    func updateNSView(_ nsView: UpdatableMacView, context: Context) {
        // Update our video layer.
        context.coordinator.contentViewModel.setPreviewView(to: nsView)
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

