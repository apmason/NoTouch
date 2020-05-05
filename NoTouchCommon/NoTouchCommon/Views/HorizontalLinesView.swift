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
    private let numLines: Int = 3
    
    func offsetForIndex(_ index: Int, contentHeight: CGFloat) -> CGFloat {
        let graphSize = contentHeight - topOffset - offsetFromBottom
        let sectionSize = graphSize / 3
        return sectionSize * CGFloat(index)
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for i in 0..<self.numLines {
                    path.move(to:
                        CGPoint(x: self.xOffset,
                                y: self.topOffset + self.offsetForIndex(i, contentHeight: geometry.size.height))
                    )
                    
                    path.addLine(to:
                        CGPoint(x: geometry.size.width,
                                y: self.topOffset + self.offsetForIndex(i, contentHeight: geometry.size.height))
                    )
                }
            }
            .stroke(Color.black, lineWidth: 1)
        }
    }
}

struct HorizontalLines_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalLinesView(xOffset: 20, offsetFromBottom: 20, topOffset: 20)
            .frame(width: 300, height: 300)
    }
}
