//
//  VideoLayerView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AppKit
import Foundation
import SwiftUI
import NoTouchCommon

class UpdatableView: NSView, NativewView {    
    
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

struct VideoLayerView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSView {
        let view = UpdatableView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        //
    }
}
