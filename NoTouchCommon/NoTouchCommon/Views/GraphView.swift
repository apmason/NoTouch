//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    
    /// The offset of the top axis from the very top of the graph.
    private var topYOffset: CGFloat = 20
    
    /// The offset of the y axis
    private var bottomYOffset: CGFloat = 30
    
    /// The offset of the x axis
    private var leadingXOffset: CGFloat = 40
    
    private var lineWidth: CGFloat = 0.5
    
    private let offsetCalculator: OffsetCalculator
    
    init() {
        self.offsetCalculator = OffsetCalculator(topYOffset: topYOffset,
                                                 bottomYOffset: bottomYOffset,
                                                 leadingXOffset: leadingXOffset)
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                AxisView(lineWidth: self.lineWidth,
                         leadingXOffset: self.leadingXOffset,
                         bottomYOffset: self.bottomYOffset)
                
                VerticalLinesView(numberOfLines: 3,
                                  bottomOffset: self.bottomYOffset + self.lineWidth * 1.5,
                                  xOffset: self.leadingXOffset,
                                  offsetCalculator: self.offsetCalculator)
                
                HorizontalLinesView(xOffset: self.leadingXOffset + (self.lineWidth / 2),
                                    offsetFromBottom: self.bottomYOffset,
                                    topOffset: self.topYOffset,
                                    offsetCalculator: self.offsetCalculator)
                
                Group {
                    // Y Axis Labels
                    YAxisLabel(text: "200")
                        .position(x: (self.leadingXOffset / 2),
                                  y: self.topYOffset)
                    
                    YAxisLabel(text: "200")
                        .position(x: (self.leadingXOffset / 2),
                                  y: self.offsetCalculator.yAxisLabelOffsetFor(index: 1,
                                                                               contentHeight: geometry.size.height))
                    
                    YAxisLabel(text: "200")
                        .position(x: (self.leadingXOffset / 2),
                                  y: self.offsetCalculator.yAxisLabelOffsetFor(index: 2,
                                                                               contentHeight: geometry.size.height))
                }
                
                Group {
                    // X Axis Labels
                    Text("6am")
                        .frame(width: 40, height: 40, alignment: .leading)
                        .position(x: self.leadingXOffset + 20,
                                  y: geometry.size.height - (self.bottomYOffset / 2))
                    
                    Text("12pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 1, contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.bottomYOffset / 2))
                    
                    Text("6pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 2,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.bottomYOffset / 2))
                    
                    Text("12am")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 3,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.bottomYOffset / 2))
                }
                
                BarsView()
                    .frame(width: geometry.size.width - self.leadingXOffset,
                           height: geometry.size.height - self.bottomYOffset)
                    .position(x: (geometry.size.width - self.leadingXOffset) / 2,
                              y: (geometry.size.height - self.bottomYOffset - self.topYOffset) / 2)
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
