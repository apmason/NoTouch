//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

public struct GraphView: View {
    
    let positioner = Positioner()
    
    @ObservedObject public var recordHolder: RecordHolder
    
    public init(recordHolder: RecordHolder) {
        self.recordHolder = recordHolder
    }

    public var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                AxisView(lineWidth: self.positioner.lineWidth,
                         leadingXOffset: self.positioner.leadingXOffset,
                         bottomYOffset: self.positioner.bottomYOffset)
                
                VerticalLinesView(numberOfLines: 3,
                                  bottomOffset: self.positioner.bottomYOffset + self.positioner.lineWidth * 1.5,
                                  xOffset: self.positioner.leadingXOffset,
                                  positioner: self.positioner)
                
                HorizontalLinesView(xOffset: self.positioner.leadingXOffset + (self.positioner.lineWidth / 2),
                                    offsetFromBottom: self.positioner.bottomYOffset,
                                    topOffset: self.positioner.topYOffset,
                                    positioner: self.positioner)
                
                // Y Axis Labels
                GraphYLabels(positioner: self.positioner,
                             highestYValue: self.recordHolder.topAxisValue)
                
                // X Axis Labels
                GraphXLabels(positioner: self.positioner)
                
                BarsView(recordHolder: self.recordHolder, spacing: 5)
                    .frame(width: geometry.size.width - self.positioner.leadingXOffset,
                           height: geometry.size.height - self.positioner.bottomYOffset - self.positioner.topYOffset)
                    .position(x: self.positioner.leadingXOffset + ((geometry.size.width - self.positioner.leadingXOffset) / 2),
                              y: (geometry.size.height - self.positioner.topYOffset - self.positioner.bottomYOffset) / 2 + self.positioner.topYOffset)
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    
    static var dummyData: [Touch] {
        var data: [Touch] = [Touch].init(repeating: 0, count: 24)
        for i in 0..<data.count {
            data[i] = Int.random(in: 0...100)
        }
        
        return data
    }
    
    // FIXME: fill with dummy data.
    static var previews: some View {
        GraphView(recordHolder: RecordHolder())
    }
}
