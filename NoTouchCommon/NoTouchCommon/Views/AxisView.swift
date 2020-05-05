//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct AxisView: View {
    
    /// The offset of the y axis
    private var yAxisOffset: CGFloat = 30
    
    /// The offset of the x axis
    private var xAxisOffset: CGFloat = 40
    
    private var lineWidth: CGFloat = 0.5
    
    /// The offset of the top axis from the very top of the graph.
    private var topOffset: CGFloat = 20
    
    func yLabelOffsetForIndex(_ index: Int, contentHeight: CGFloat) -> CGFloat {
        let graphSize = contentHeight - topOffset - yAxisOffset
        let sectionSize = graphSize / 3
        return sectionSize * CGFloat(index) + self.topOffset
    }
    
    func xLabelOffsetForIndex(_ index: Int, contentWidth: CGFloat) -> CGFloat {
        let graphSize = contentWidth - xAxisOffset
        let sectionSize = graphSize / 4
        return sectionSize * CGFloat(index) + xAxisOffset
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                Path { path in
                    // Y Axis
                    // bottom left corner
                    path.move(to:
                        CGPoint(x: self.xAxisOffset,
                                y: geometry.size.height - self.yAxisOffset)
                    )
                    // straight up
                    path.addLine(to:
                        CGPoint(x: self.xAxisOffset,
                                y: 0)
                    )
                    
                    // X Axis
                    // bottom left corner
                    path.move(to:
                        CGPoint(x: self.xAxisOffset + (self.lineWidth / 2),
                                y: geometry.size.height - (self.lineWidth / 2) - self.yAxisOffset)
                    )
                    // To the left
                    path.addLine(to:
                        CGPoint(x: geometry.size.width,
                                y: geometry.size.height - (self.lineWidth / 2) - self.yAxisOffset)
                    )
                }
                .stroke(Color.blue, lineWidth: self.lineWidth)
                
                VerticalLinesView(numberOfLines: 3,
                              bottomOffset: self.yAxisOffset + self.lineWidth * 1.5,
                              xOffset: self.xAxisOffset)
                
                HorizontalLinesView(xOffset: self.xAxisOffset + (self.lineWidth / 2),
                                offsetFromBottom: self.yAxisOffset,
                                topOffset: self.topOffset)
                
                // Y Axis Labels
                YAxisLabel(text: "200")
                    .position(x: (self.xAxisOffset / 2),
                              y: self.topOffset)
                
                YAxisLabel(text: "200")
                    .position(x: (self.xAxisOffset / 2),
                              y: self.yLabelOffsetForIndex(1, contentHeight: geometry.size.height))
                
                YAxisLabel(text: "200")
                .position(x: (self.xAxisOffset / 2),
                          y: self.yLabelOffsetForIndex(2, contentHeight: geometry.size.height))
                
                // X Axis Labels
                Text("6am")
                    .frame(width: 40, height: 40, alignment: .leading)
                    .position(x: self.xAxisOffset + 20,
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("12pm")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.xLabelOffsetForIndex(1, contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("6pm")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.xLabelOffsetForIndex(2, contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("12am")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.xLabelOffsetForIndex(3, contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
            }
        }
    }
}

struct AxisView_Previews: PreviewProvider {
    static var previews: some View {
        AxisView()
    }
}
