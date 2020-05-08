//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    
    private let offsetCalculator = OffsetCalculator()
    
    @Binding var touchObservances: [Touch]
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                AxisView(lineWidth: self.offsetCalculator.lineWidth,
                         leadingXOffset: self.offsetCalculator.leadingXOffset,
                         bottomYOffset: self.offsetCalculator.bottomYOffset)
                
                VerticalLinesView(numberOfLines: 3,
                                  bottomOffset: self.offsetCalculator.bottomYOffset + self.offsetCalculator.lineWidth * 1.5,
                                  xOffset: self.offsetCalculator.leadingXOffset,
                                  offsetCalculator: self.offsetCalculator)
                
                HorizontalLinesView(xOffset: self.offsetCalculator.leadingXOffset + (self.offsetCalculator.lineWidth / 2),
                                    offsetFromBottom: self.offsetCalculator.bottomYOffset,
                                    topOffset: self.offsetCalculator.topYOffset,
                                    offsetCalculator: self.offsetCalculator)
                
                // Y Axis Labels
                Group {
                    // Y Axis Labels
                    YAxisLabel(text: "200")
                        .position(x: (self.offsetCalculator.leadingXOffset / 2),
                                  y: self.offsetCalculator.topYOffset)
                    
                    YAxisLabel(text: "200")
                        .position(x: (self.offsetCalculator.leadingXOffset / 2),
                                  y: self.offsetCalculator.yAxisLabelOffsetFor(index: 1,
                                                                               contentHeight: geometry.size.height))
                    
                    YAxisLabel(text: "200")
                        .position(x: (self.offsetCalculator.leadingXOffset / 2),
                                  y: self.offsetCalculator.yAxisLabelOffsetFor(index: 2,
                                                                               contentHeight: geometry.size.height))
                }
                
                // X Axis Labels
                Group {
                    Text("6am")
                        .frame(width: 40, height: 40, alignment: .leading)
                        .position(x: self.offsetCalculator.leadingXOffset + 20,
                                  y: geometry.size.height - (self.offsetCalculator.bottomYOffset / 2))
                    
                    Text("12pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 1, contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.offsetCalculator.bottomYOffset / 2))
                    
                    Text("6pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 2,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.offsetCalculator.bottomYOffset / 2))
                    
                    Text("12am")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.offsetCalculator.xAxisLabelOffsetFor(index: 3,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.offsetCalculator.bottomYOffset / 2))
                }
                
                BarsView(touchObservances: self.$touchObservances)
                    .frame(width: geometry.size.width - self.offsetCalculator.leadingXOffset,
                           height: geometry.size.height - self.offsetCalculator.bottomYOffset - self.offsetCalculator.topYOffset)
                    .position(x: self.offsetCalculator.leadingXOffset + ((geometry.size.width - self.offsetCalculator.leadingXOffset) / 2),
                              y: self.offsetCalculator.topYOffset + (geometry.size.height - self.offsetCalculator.bottomYOffset - self.offsetCalculator.topYOffset) / 2)
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    
    static let dummyData: [Touch] = [
        1, 3, 4, 2, 5, 5,
        2, 3, 34, 4, 3, 4,
        5, 4, 3, 4, 5, 4,
        23, 56, 23, 54, 2
    ]
    
    static var previews: some View {
        GraphView(touchObservances: .constant(dummyData))
    }
}
