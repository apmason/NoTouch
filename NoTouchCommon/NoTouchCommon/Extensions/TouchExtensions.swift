//
//  TouchExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import Foundation

extension Collection where Element == Touch {
    
    /// Based on the highest value in the collection, this value is the next highest `Touch` value that is divisible by 5 or 10, or the highest value itself if it is already divisible by 5 or 10.
    var topAxisValue: Touch {
        var maxValue = self.max() ?? 0
        while maxValue % 5 != 0 && maxValue % 10 != 0 {
            maxValue += 1
        }
        return maxValue
    }
}

extension Touch {
    
    
    /// The ratio between the current `Touch` value and the `value` parameter.
    /// - Parameter value: The denominator to use in the ratio calculation.
    /// - Returns: The current value divided by the `value` parameter.
    func ratio(withTopValue value: Touch) -> CGFloat {
        if self == 0 {
            return 0
        }
        let ratio = CGFloat(self) / CGFloat(value)
        print("Ratio is \(ratio)")
        return ratio
    }
}
