//
//  GraphYLabels.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphYLabels: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    let positioner: Positioner
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                YAxisLabel(text: "\(self.userSettings.recordHolder.axisValue(for: .top))",
                    leadingXOffset: self.positioner.leadingXOffset)
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.topYOffset)
                
                YAxisLabel(text: "\(self.userSettings.recordHolder.axisValue(for: .middle))",
                    leadingXOffset: self.positioner.leadingXOffset)
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.yAxisLabelOffsetFor(index: 1,
                                                                     contentHeight: geometry.size.height))
                
                YAxisLabel(text: "\(self.userSettings.recordHolder.axisValue(for: .bottom))",
                    leadingXOffset: self.positioner.leadingXOffset)
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
            .environmentObject(UserSettings())
    }
}
