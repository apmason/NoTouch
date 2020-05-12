//
//  TimeLinesView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct VerticalLinesView: View {
    
    let numberOfLines: Int
    let bottomOffset: CGFloat
    let xOffset: CGFloat
    let positioner: Positioner
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for i in 1...self.numberOfLines {
                    path.move(to:
                        CGPoint(x: self.positioner.xAxisLabelOffsetFor(line: i,
                                                                             contentWidth: geometry.size.width),
                                y: geometry.size.height - self.bottomOffset)
                    )
                    
                    path.addLine(to:
                        CGPoint(x: self.positioner.xAxisLabelOffsetFor(line: i,
                                                                             contentWidth: geometry.size.width),
                                y: 0)
                    )
                }
            }
            .stroke(Color.gray, lineWidth: self.positioner.lineWidth)
        }
    }
}

struct TimeLinesView_Previews: PreviewProvider {
    static let xOffset: CGFloat = 40
    
    static var previews: some View {
        VerticalLinesView(numberOfLines: 3,
                          bottomOffset: 2,
                          xOffset: xOffset,
                          positioner: Positioner()
        )
            .frame(width: 300, height: 300)
    }
}
