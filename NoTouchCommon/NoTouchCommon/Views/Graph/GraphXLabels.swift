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
    
    private let textWidth: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                XLabel("12am")
                    .frame(width: self.textWidth, height: 40, alignment: .leading)
                    .position(x: self.positioner.leadingXOffset + (self.textWidth / 2),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("6am") // add 20 to X position to offset half of own width. Do for all 4 labels.
                    .frame(width: self.textWidth, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 1, contentWidth: geometry.size.width) + (self.textWidth / 2),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("12pm")
                    .frame(width: self.textWidth, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 2, contentWidth: geometry.size.width) + (self.textWidth / 2),
                              y: geometry.size.height - (self.positioner.bottomYOffset / 2))
                
                XLabel("6pm")
                    .frame(width: self.textWidth, height: 40, alignment: .center)
                    .position(x: self.positioner.xAxisLabelOffsetFor(line: 3, contentWidth: geometry.size.width) + (self.textWidth / 2),
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
