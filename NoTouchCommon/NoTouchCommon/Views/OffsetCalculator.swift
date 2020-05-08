//
//  OffsetCalculator.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

class OffsetCalculator {
    
    let topYOffset: CGFloat = 20
    
    /// The offset of the y axis
    let bottomYOffset: CGFloat = 30
    
    /// The offset of the x axis
    let leadingXOffset: CGFloat = 40
    
    let lineWidth: CGFloat = 0.5
    
//    init(topYOffset: CGFloat, bottomYOffset: CGFloat, leadingXOffset: CGFloat) {
//        self.topYOffset = topYOffset
//        self.bottomYOffset = bottomYOffset
//        self.leadingXOffset = leadingXOffset
//    }
    
    func yAxisLabelOffsetFor(index: Int, contentHeight: CGFloat) -> CGFloat {
        let graphSize = contentHeight - topYOffset - bottomYOffset
        let sectionSize = graphSize / 3
        return sectionSize * CGFloat(index) + self.topYOffset
    }
    
    func xAxisLabelOffsetFor(index: Int, contentWidth: CGFloat) -> CGFloat {
        let graphSize = contentWidth - leadingXOffset
        let sectionSize = graphSize / 4
        return sectionSize * CGFloat(index) + leadingXOffset
    }
}
