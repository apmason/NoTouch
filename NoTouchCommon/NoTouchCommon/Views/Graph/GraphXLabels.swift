//
//  GraphXLabels.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphXLabels: View {
    
    let positioner: Positioner
    var body: some View {
        GeometryReader { geometry in
            Group {
                Text("6am")
                    .frame(width: 40, height: 40, alignment: .leading)
                    .position(x: self.positioner.leadingXOffset + 20,
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                Text("12pm")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 1, contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                Text("6pm")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 2,
                                                                     contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                Text("12am")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 3,
                                                                     contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
            }
        }
    }
}

struct GraphXLabels_Previews: PreviewProvider {
    static var previews: some View {
        GraphXLabels(positioner: Positioner())
    }
}
