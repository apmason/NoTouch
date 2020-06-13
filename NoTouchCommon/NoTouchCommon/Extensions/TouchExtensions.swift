//
//  TouchExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import Foundation

extension Touch {
    
    
    /// The ratio between the current `Touch` value and the `value` parameter.
    /// - Parameter value: The denominator to use in the ratio calculation.
    /// - Returns: The current value divided by the `value` parameter.
    func ratio(withTopValue value: Touch) -> CGFloat {
        if self == 0 {
            return 0
        }
        return CGFloat(self) / CGFloat(value)
    }
}
