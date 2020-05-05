//
//  OffsetCalculator.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

struct OffsetCalculator {
    
    let topYOffset: CGFloat
    let bottomYOffset: CGFloat
    let leadingXOffset: CGFloat
    
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
