//
//  TimeLinesView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct VerticalLinesView: View {
    
    var numberOfLines: Int
    var bottomOffset: CGFloat
    var xOffset: CGFloat
    
    func xOffsetForIndex(_ index: Int, contentHeight: CGFloat) -> CGFloat {
        let graphSize = contentHeight - xOffset
        let sectionSize = graphSize / CGFloat(numberOfLines + 1)
        return sectionSize * CGFloat(index) + xOffset
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for line in 1...self.numberOfLines {
                    path.move(to:
                        CGPoint(x: self.xOffsetForIndex(line, contentHeight: geometry.size.width),
                                y: geometry.size.height - self.bottomOffset)
                    )
                    
                    path.addLine(to:
                        CGPoint(x: self.xOffsetForIndex(line, contentHeight: geometry.size.width),
                                y: 0)
                    )
                }
            }
            .stroke(Color.black, lineWidth: 0.5)
        }
    }
}

struct TimeLinesView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalLinesView(numberOfLines: 3, bottomOffset: 2, xOffset: 40)
            .frame(width: 300, height: 300)
    }
}
