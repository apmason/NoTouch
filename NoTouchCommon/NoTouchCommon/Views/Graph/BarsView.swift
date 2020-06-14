//
//  BarsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

extension Animation {
    static func ripple() -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(3)
    }
}

struct BarsView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @Binding var selectedBar: SelectedBar?
    let spacing: CGFloat
    private let barCornerRadius: CGFloat = 2
    
    func rectangleWidth(for totalWidth: CGFloat) -> CGFloat {
        let section = totalWidth / 4
        let totalSpace = 6 * spacing
        let barSpace = section - totalSpace
        let barSize = barSpace / 6
        return barSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            // add a half spacer
            HStack(alignment: .bottom, spacing: 0) {
                Rectangle().frame(width: self.spacing / 2, height: 0) // Initial spacer (seperates from leading axis)
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(self.userSettings.recordHolder.hourlyData, id: \.id) { hour in
                        // Create a Rectangle that takes up all the space between the tap of the bar and the top of the screen in order to detect taps.
                        ZStack(alignment: .bottom) {
                            Rectangle() // The invisible backing view to detect taps that aren't on the colored in bar.
                                .fill(Color.black.opacity(0.00000000001)) // can't detect taps on view with opacity of 0
                                .frame(width: self.rectangleWidth(for: geometry.size.width) + self.spacing,
                                       height: geometry.size.height) // The whole BarView will be covered with these.
                                .gesture(
                                    TapGesture()
                                        .onEnded({ _ in
                                            self.touchDetected(hour, geometryWidth: geometry.size.width, geometryHeight: geometry.size.height)
                                        })
                            )
                            
                            Rectangle() // The visible colored in bar representing the data.
                                .fill(Color.orange)
                                .cornerRadius(self.barCornerRadius)
                                .overlay(CornerCoverer(radius: self.barCornerRadius).fill(Color.orange))
                                .frame(width: self.rectangleWidth(for: geometry.size.width),
                                       height: hour.touches.ratio(withTopValue: self.userSettings.recordHolder.hourlyData.topAxisValue) * geometry.size.height)
                                .animation(.ripple())
                                .gesture(
                                    TapGesture()
                                        .onEnded({ _ in
                                            self.touchDetected(hour, geometryWidth: geometry.size.width, geometryHeight: geometry.size.height)
                                        })
                            )
                        }
                    }
                }
                Rectangle().frame(width: self.spacing / 2, height: 0) // Final spacer (seperates from trailing axis)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height,
                   alignment: .bottom)
        }
    }
    
    /// If a touch is detected either on a visible bar or it's hidden backing view, call this function to update the currently selected bar. If no touches have been registered for the given bar and there is not a bar with touches nearby, the `selectedBar` property is set to nil.
    private func touchDetected(_ hour: HourlyData, geometryWidth: CGFloat, geometryHeight: CGFloat) {
        var dataPoint: HourlyData?
        
        // Use the currently selected hour.
        if hour.touches > 0 {
            dataPoint = hour
        }
        else {
            // Search on either side of this data point (accounting for zero indexing and array count). If no suitable value is found, increment search value until the hit limit is hit.
            for searchIndex in 1...(userSettings.recordHolder.hourlyData.count / 6) {
                let upIndex = min(hour.index + searchIndex, userSettings.recordHolder.hourlyData.count - 1)
                if userSettings.recordHolder.hourlyData[upIndex].touches > 0 {
                    dataPoint = userSettings.recordHolder.hourlyData[upIndex]
                    break
                }
                
                let downIndex = max(0, hour.index - searchIndex)
                if userSettings.recordHolder.hourlyData[downIndex].touches > 0 {
                    dataPoint = userSettings.recordHolder.hourlyData[downIndex]
                    break
                }
            }
        }
        
        // Make sure we have a datapoint and that we aren't reselecting the previously selected bar.
        guard let unwrappedDataPoint = dataPoint, selectedBar?.barIndex != unwrappedDataPoint.index else {
            self.selectedBar = nil
            return
        }
        
        self.selectedBar = SelectedBar(barIndex: unwrappedDataPoint.index,
                                       barWidth: self.rectangleWidth(for: geometryWidth),
                                       barHeight: unwrappedDataPoint.touches.ratio(withTopValue: self.userSettings.recordHolder.hourlyData.topAxisValue) * geometryHeight,
                                       hourlyData: unwrappedDataPoint)
    }
}

struct BarsView_Previews: PreviewProvider {
    
    static var previews: some View {
        BarsView(selectedBar: .constant(nil), spacing: 10)
            .environmentObject(UserSettings())
    }
}
