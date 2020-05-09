//
//  NativeView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import Foundation
import QuartzCore

/// A protocol that defines a cross-platform view.
public protocol NativeView: class {
    
    var nativeLayer: CALayer? { get set }
    var nativeFrame: CGRect { get }
    var nativeBounds: CGRect { get }
    func setToWantLayer(_ wantsLayer: Bool)
}
