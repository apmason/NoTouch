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
    
    static func defaultText(size: CGFloat) -> Font {
        Font.custom("Poppins-Regular", size: size)
    }
}
