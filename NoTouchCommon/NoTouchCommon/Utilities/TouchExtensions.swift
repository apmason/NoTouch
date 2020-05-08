//
//  TouchExtensions.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

extension Collection where Element == Touch {
    
    func topAxisValue() -> Touch {
        var maxValue = self.max() ?? 0
        while maxValue % 5 != 0 && maxValue % 10 != 0 {
            maxValue += 1
        }
        return maxValue
    }
}

extension Touch {
    
    func ratio(withTopValue value: Touch) -> CGFloat{
        return CGFloat(self) / CGFloat(value)
    }
}
