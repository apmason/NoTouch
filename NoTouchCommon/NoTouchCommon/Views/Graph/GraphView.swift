//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    
    private let positioner = Positioner()
    
    @Binding var touchObservances: [Touch]
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                AxisView(lineWidth: self.positioner.lineWidth,
                         leadingXOffset: self.positioner.leadingXOffset,
                         bottomYOffset: self.positioner.bottomYOffset)
                
                VerticalLinesView(numberOfLines: 3,
                                  bottomOffset: self.positioner.bottomYOffset + self.positioner.lineWidth * 1.5,
                                  xOffset: self.positioner.leadingXOffset,
                                  offsetCalculator: self.positioner)
                
                HorizontalLinesView(xOffset: self.positioner.leadingXOffset + (self.positioner.lineWidth / 2),
                                    offsetFromBottom: self.positioner.bottomYOffset,
                                    topOffset: self.positioner.topYOffset,
                                    positioner: self.positioner)
                
                // Y Axis Labels
                GraphYLabels(positioner: self.positioner)
                
                // X Axis Labels
                Group {
                    Text("6am")
                        .frame(width: 40, height: 40, alignment: .leading)
                        .position(x: self.positioner.leadingXOffset + 20,
                                  y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                    
                    Text("12pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.positioner.xAxisLabelOffsetFor(index: 1, contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                    
                    Text("6pm")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.positioner.xAxisLabelOffsetFor(index: 2,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                    
                    Text("12am")
                        .frame(width: 40, height: 40, alignment: .center)
                        .position(x: self.positioner.xAxisLabelOffsetFor(index: 3,
                                                                               contentWidth: geometry.size.width),
                                  y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                }
                
                BarsView(touchObservances: self.$touchObservances)
                    .frame(width: geometry.size.width - self.positioner.leadingXOffset,
                           height: geometry.size.height - self.positioner.bottomYOffset - self.positioner.topYOffset)
                    .position(x: self.positioner.leadingXOffset + ((geometry.size.width - self.positioner.leadingXOffset) / 2),
                              y: (geometry.size.height - self.positioner.topYOffset - self.positioner.bottomYOffset) / 2 + self.positioner.topYOffset)
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
