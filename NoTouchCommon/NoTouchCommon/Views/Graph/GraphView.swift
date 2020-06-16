//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Combine
import SwiftUI

class SelectedBar {
    let barIndex: Int
    let barWidth: CGFloat
    let barHeight: CGFloat
    @Published var hourlyData: HourlyData
    let userSettings: UserSettings
    
    private var cancellableObservation: AnyCancellable?
        
    init(barIndex: Int, barWidth: CGFloat, barHeight: CGFloat, hourlyData: HourlyData, userSettings: UserSettings) {
        self.barIndex = barIndex
        self.barWidth = barWidth
        self.barHeight = barHeight
        self.hourlyData = hourlyData
        self.userSettings = userSettings
        
        setupObserver()
    }
    
    func setupObserver() {
        self.cancellableObservation = userSettings.$recordHolder.sink(receiveValue: { [weak self] recordHolder in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                
                // Get day's current hour
                let currentHour = Calendar.current.component(.hour, from: Date())
                
                // Latest date is selected, update data.
                if self.barIndex == currentHour {
                    self.hourlyData = self.userSettings.recordHolder.hourlyData[self.barIndex]
                }
            }
        })
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
}

public struct GraphView: View {
    
    private let positioner: Positioner

    public init(leadingXOffset: CGFloat) {
        self.positioner = Positioner(leadingXOffset: leadingXOffset)
    }
    
    @State var selectedBar: SelectedBar?
    
    private let barSpacing: CGFloat = 5
    
    /// The spacing of the info pointer that extends beyond the graph view to the info view
    private let infoSpacing: CGFloat = 25
    
    private var backgroundColor: Color {
        if selectedBar == nil {
            return Color.clear
        } else {
            return GraphConstants.pickerColor
        }
    }
    
    @State var rect: CGRect = .zero
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Rectangle().fill(Color.blue.opacity(0.000000001)) // This view handles taps on the tap portion of the screen and dismisses the selected bar view by setting it to nil.
                .onTapGesture {
                    self.selectedBar = nil
            }
            
            VStack(alignment: .leading, spacing: 12) {
                GeometryReader { geometry in
                    SelectedInfoView(selectedBar: self.$selectedBar)
                        .padding(10)
                        .background(self.backgroundColor)
                        .cornerRadius(12)
                        .padding(.leading, (self.selectedBar != nil ? 0 : self.positioner.leadingXOffset))
                        .if(self.selectedBar != nil) { view in
                            view.position(x: self.selectedBar != nil ? self.selectedPointerXPosition() : 0, y: geometry.size.height / 2)
                    }
                    .onTapGesture {
                        self.selectedBar = nil
                    }
                }.frame(height: 90)
                
                // Graph portion
                GeometryReader { geometry in
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
                        .onTapGesture {
                            self.selectedBar = nil
                        }
                        
                        // X Axis Labels
                        GraphXLabels(positioner: self.positioner)
                        .onTapGesture {
                            self.selectedBar = nil
                        }
                        
                        if self.selectedBar != nil {
                            SelectedPointerView(selectedBar: self.$selectedBar,
                                                     barViewHeight: self.barViewHeight(totalHeight: geometry.size.height),
                                                     infoSpacing: self.infoSpacing,
                                                     topYOffset: self.positioner.topYOffset)
                                .position(x: self.selectedPointerXPosition(),
                                          y: self.selectedPointerYPosition(totalViewHeight: geometry.size.height))
                        }
                        
                        BarsView(selectedBar: self.$selectedBar, spacing: self.barSpacing)
                            .frame(width: geometry.size.width - self.positioner.leadingXOffset,
                                   height: self.barViewHeight(totalHeight: geometry.size.height))
                            .position(x: self.positioner.leadingXOffset + ((geometry.size.width - self.positioner.leadingXOffset) / 2),
                                      y: (geometry.size.height - self.positioner.topYOffset - self.positioner.bottomYOffset) / 2 + self.positioner.topYOffset - self.positioner.lineWidth)
                    }
                }
            }
        }
    }
    
    /// Returns the offset that will set the center of a View on the center of the SelectedBar. Force unwrapping the `selectedBar` is done, so ensure `selectedBar` isn't `nil`.
    private func selectedPointerXPosition() -> CGFloat {
        let index = CGFloat(selectedBar!.barIndex)
        let spacingOffset = (barSpacing / 2) + (index * barSpacing)
        let barOffset = (selectedBar!.barWidth / 2) + (index * selectedBar!.barWidth)
        return self.positioner.leadingXOffset + spacingOffset + barOffset
    }
    
    /// Return the selected bar Y position
    private func selectedPointerYPosition(totalViewHeight: CGFloat) -> CGFloat {
        let selectorHeight = SelectedPointerView.selectedPointerHeight(barViewHeight: barViewHeight(totalHeight: totalViewHeight),
                                                                       selectedBarHeight: self.selectedBar!.barHeight,
                                                                       infoSpacing: self.infoSpacing,
                                                                       topYOffset: self.positioner.topYOffset)
        
        let bottomSectionHeight = (selectorHeight / 2) + self.positioner.bottomYOffset + self.selectedBar!.barHeight
        return totalViewHeight - bottomSectionHeight
    }
    
    /// Return the height of the total bar view (the view that contains all the bars).
    private func barViewHeight(totalHeight: CGFloat) -> CGFloat {
        return totalHeight - self.positioner.bottomYOffset - self.positioner.topYOffset - self.positioner.lineWidth
    }
}

struct SelectedPointerView: View {
    @Binding var selectedBar: SelectedBar?
    let barViewHeight: CGFloat
    let infoSpacing: CGFloat
    let topYOffset: CGFloat
    
    public var body: some View {
        Rectangle()
            .fill(GraphConstants.pickerColor)
            .frame(width: 3,
                   height: SelectedPointerView.selectedPointerHeight(barViewHeight: barViewHeight, selectedBarHeight: selectedBar?.barHeight ?? 0, infoSpacing: infoSpacing, topYOffset: topYOffset))
    }
    
    static func selectedPointerHeight(barViewHeight: CGFloat, selectedBarHeight: CGFloat, infoSpacing: CGFloat, topYOffset: CGFloat) -> CGFloat {
        let totalHeight = infoSpacing + barViewHeight
        let selectorHeight = totalHeight - selectedBarHeight + topYOffset
        return selectorHeight
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
