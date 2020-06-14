//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct SelectedBar {
    let barWidth: CGFloat
    let barIndex: Int
}

public struct GraphView: View {
    
    private let positioner: Positioner

    public init(leadingXOffset: CGFloat) {
        self.positioner = Positioner(leadingXOffset: leadingXOffset)
    }
    
    @State var selectedBar: SelectedBar?
    
    private let barSpacing: CGFloat = 5
    
    @ViewBuilder
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
                
                BarsView(selectedBar: self.$selectedBar, spacing: self.barSpacing)
                    .frame(width: geometry.size.width - self.positioner.leadingXOffset,
                           height: geometry.size.height - self.positioner.bottomYOffset - self.positioner.topYOffset - self.positioner.lineWidth)
                    .position(x: self.positioner.leadingXOffset + ((geometry.size.width - self.positioner.leadingXOffset) / 2),
                              y: (geometry.size.height - self.positioner.topYOffset - self.positioner.bottomYOffset) / 2 + self.positioner.topYOffset - self.positioner.lineWidth)
                
                if self.selectedBar != nil {
                    SelectedBarView()
                        .frame(width: 5, height: 30)
                        .position(x: self.selectedBarWidthOffset(), y: 100)
                }
            }
        }
    }
    
    /// Returns the offset that will set the center of a View on the center of the SelectedBar. Force unwrapping the `selectedBar` is done, so ensure `selectedBar` isn't `nil`.
    private func selectedBarWidthOffset() -> CGFloat {
        let index = CGFloat(selectedBar!.barIndex)
        let spacingOffset = (barSpacing / 2) + (index * barSpacing)
        let barOffset = (selectedBar!.barWidth / 2) + (index * selectedBar!.barWidth)
        return self.positioner.leadingXOffset + spacingOffset + barOffset
    }
}

struct SelectedBarView: View {
    public var body: some View {
        Rectangle()
            .fill(Color.yellow)
    }
}

struct GraphView_Previews: PreviewProvider {
    
    static var userSettings: UserSettings {
        let userSettings = UserSettings()
        userSettings.recordHolder.add(dummyRecordWith(date: Date()))
        userSettings.recordHolder.add(dummyRecordWith(date: Date()))
        userSettings.recordHolder.add(dummyRecordWith(date: Date()))
        return userSettings
    }
    
    // FIXME: fill with dummy data.
    static var previews: some View {
        GraphView(leadingXOffset: 20)
            .environmentObject(userSettings)
    }
    
    private static func dummyRecordWith(date: Date) -> TouchRecord {
        return TouchRecord(deviceName: "test",
                           timestamp: date,
                           version: "123",
                           origin: .database)
    }
}
