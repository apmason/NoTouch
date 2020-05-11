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
    
    enum LabelPosition {
        case top
        case middle
        case bottom
    }
    
    let positioner: Positioner
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                YAxisLabel(text: "\(self.valueForYLabel(for: .top))")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.topYOffset)
                
                YAxisLabel(text: "\(self.valueForYLabel(for: .middle))")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.yAxisLabelOffsetFor(index: 1,
                                                                     contentHeight: geometry.size.height))
                
                YAxisLabel(text: "\(self.valueForYLabel(for: .bottom))")
                    .position(x: (self.positioner.leadingXOffset / 2),
                              y: self.positioner.yAxisLabelOffsetFor(index: 2,
                                                                     contentHeight: geometry.size.height))
            }
        }
    }
    
    func valueForYLabel(for position: LabelPosition) -> Touch {
        switch position {
        case .top:
            return self.userSettings.recordHolder.topAxisValue
            
        case .middle:
            return (self.userSettings.recordHolder.topAxisValue / 3) * 2
            
        case .bottom:
            return (self.userSettings.recordHolder.topAxisValue / 3)
            
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
