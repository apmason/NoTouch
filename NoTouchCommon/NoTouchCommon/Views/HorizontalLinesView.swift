//
//  HorizontalLines.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct HorizontalLinesView: View {
    
    let xOffset: CGFloat
    let offsetFromBottom: CGFloat
    let topOffset: CGFloat
    let positioner: Positioner
    private let numLines: Int = 3
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for i in 0..<self.numLines {
                    path.move(to:
                        CGPoint(x: self.xOffset,
                                y: self.positioner.yAxisLabelOffsetFor(index: i,
                                                                             contentHeight: geometry.size.height))
                    )
                    
                    path.addLine(to:
                        CGPoint(x: geometry.size.width,
                                y: self.positioner.yAxisLabelOffsetFor(index: i,
                                                                             contentHeight: geometry.size.height))
                    )
                }
            }
            .stroke(Color.black, lineWidth: 1)
        }
    }
}

struct HorizontalLines_Previews: PreviewProvider {
    
    static let xOffset: CGFloat = 20
    static let offsetFromBottom: CGFloat = 20
    static let topOffset: CGFloat = 20
    
    static var previews: some View {
        HorizontalLinesView(xOffset: xOffset,
                            offsetFromBottom: offsetFromBottom,
                            topOffset: topOffset,
                            offsetCalculator: Positioner()
        )
            .frame(width: 300, height: 300)
    }
}
