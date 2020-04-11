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
public protocol NativewView: class {
    
    var nativeLayer: CALayer? { get }
    var nativeFrame: CGRect { get }
    var nativeBounds: CGRect { get }
}
