//
//  GraphYLabels.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphYLabels: View {
    
    let positioner: Positioner
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                YAxisLabel(text: "200")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.topYOffset)
                
                YAxisLabel(text: "200")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.yAxisLabelOffsetFor(index: 1,
                                                                     contentHeight: geometry.size.height))
                
                YAxisLabel(text: "200")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.yAxisLabelOffsetFor(index: 2,
                                                                     contentHeight: geometry.size.height))
            }
        }
    }
}

struct GraphYLabels_Previews: PreviewProvider {
    static var previews: some View {
        GraphYLabels(positioner: Positioner())
            .frame(width: 200, height: 200)
    }
}
