//
//  Positioner.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreGraphics
import Foundation

public struct Positioner {
    
    let topYOffset: CGFloat
    
    /// The offset of the y axis
    let bottomYOffset: CGFloat
    
    /// The offset of the x axis
    let leadingXOffset: CGFloat
    
    let lineWidth: CGFloat
    
    init(topYOffset: CGFloat = 10,
         bottomYOffset: CGFloat = 30,
         leadingXOffset: CGFloat = 40,
         lineWidth: CGFloat = 0.2) {
        self.topYOffset = topYOffset
        self.bottomYOffset = bottomYOffset
        self.leadingXOffset = leadingXOffset
        self.lineWidth = lineWidth
    }
    
    func yAxisLabelOffsetFor(index: Int, contentHeight: CGFloat) -> CGFloat {
        let graphSize = contentHeight - topYOffset - bottomYOffset
        let sectionSize = graphSize / 3
        return sectionSize * CGFloat(index) + self.topYOffset
    }
    
    func xAxisLabelOffsetFor(line: Int, contentWidth: CGFloat) -> CGFloat {
        let graphSize = contentWidth - leadingXOffset
        let sectionSize = graphSize / 4
        return sectionSize * CGFloat(line) + leadingXOffset
    }
}
