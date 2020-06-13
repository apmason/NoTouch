//
//  NoTouchFont.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    static func sfDisplayBold(size: CGFloat) -> Font {
        Font.custom("SF-Pro-Display-Bold", size: size)
    }
    
    static func sfDisplayRegular(size: CGFloat) -> Font {
        Font.custom("SF-Pro-Display-Regular", size: size)
    }
    
    static func sfDisplayMedium(size: CGFloat) -> Font {
        Font.custom("SF-Pro-Display-Medium", size: size)
    }
    
    static func sfDisplaySemibold(size: CGFloat) -> Font {
        Font.custom("SF-Pro-Display-Semibold", size: size)
    }
}
