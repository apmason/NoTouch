//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

public struct GraphView: View {
    
    private let positioner: Positioner

    public init(leadingXOffset: CGFloat) {
        self.positioner = Positioner(leadingXOffset: leadingXOffset)
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
                GraphYLabels(positioner: self.positioner)
                
                // X Axis Labels
                GraphXLabels(positioner: self.positioner)
                
                BarsView(spacing: 5)
                    .frame(width: geometry.size.width - self.positioner.leadingXOffset,
                           height: geometry.size.height - self.positioner.bottomYOffset - self.positioner.topYOffset)
                    .position(x: self.positioner.leadingXOffset + ((geometry.size.width - self.positioner.leadingXOffset) / 2),
                              y: (geometry.size.height - self.positioner.topYOffset - self.positioner.bottomYOffset) / 2 + self.positioner.topYOffset)
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    
    // FIXME: fill with dummy data.
    static var previews: some View {
        GraphView(leadingXOffset: 20)
            .environmentObject(UserSettings())
    }
}
