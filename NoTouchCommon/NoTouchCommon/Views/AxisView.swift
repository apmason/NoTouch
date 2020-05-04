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
    
    private var lineWidth: CGFloat = 1
    
    /// The offset of the top axis from the very top of the graph.
    private var topOffset: CGFloat = 20
    
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
                
                //TimeLinesView(numberOfLines: 4,
//                              bottomOffset: self.yAxisOffset + self.lineWidth * 1.5)
//                
                HorizontalLines(xOffset: self.xAxisOffset + (self.lineWidth / 2),
                                offsetFromBottom: self.yAxisOffset,
                                topOffset: self.topOffset)
                // Y Axis Labels
                Text("200")
                    .frame(width: 35, height: 40, alignment: .trailing)
                    .position(x: (self.xAxisOffset / 2), y: self.topOffset)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .allowsTightening(true)

                // X Axis Labels
                Text("6am")
                    .frame(width: 40, height: 40)
                    .position(x: (geometry.size.width / 5),
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("12pm")
                    .frame(width: 40, height: 40)
                    .position(x: (geometry.size.width / 5) * 2,
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("6pm")
                    .frame(width: 40, height: 40)
                    .position(x: (geometry.size.width / 5) * 3,
                              y: geometry.size.height - (self.yAxisOffset / 2))
                
                Text("12am")
                    .frame(width: 40, height: 40)
                    .position(x: (geometry.size.width / 5) * 4,
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
