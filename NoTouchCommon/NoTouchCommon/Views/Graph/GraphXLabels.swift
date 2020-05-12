//
//  GraphXLabels.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct XLabel: View {

    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .allowsTightening(true)
            .font(.footnote)
    }
}

struct GraphXLabels: View {
    
    let positioner: Positioner
    var body: some View {
        GeometryReader { geometry in
            Group {
                XLabel("12am")
                    .frame(width: 40, height: 40, alignment: .leading)
                    .position(x: self.positioner.leadingXOffset + 20,
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("6am")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 1, contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("12pm")
                    .frame(width: 40, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 2,
                                                                     contentWidth: geometry.size.width),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("6pm")
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
