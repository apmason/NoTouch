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
    
    let spacing: CGFloat
    
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
                Rectangle().frame(width: self.spacing / 2, height: 0)
                HStack(alignment: .bottom, spacing: self.spacing) {
                    ForEach(self.userSettings.recordHolder.hourlyData, id: \.id) { hour in
                        // Create a Rectangle that takes up all the space between the tap of the bar and the top of the screen in order to detect taps.
                        VStack(alignment: .center, spacing: 0) {
                            Rectangle()
                                .fill(Color.black.opacity(0.00000001)) // can't detect taps on view with opacity of 0
                                .frame(width: self.rectangleWidth(for: geometry.size.width))
                            .gesture(
                                TapGesture()
                                    .onEnded({ _ in
                                        print("Top touch is: \(hour.touches)")
                                    })
                            )
                            
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: self.rectangleWidth(for: geometry.size.width),
                                       height: hour.touches.ratio(withTopValue: self.userSettings.recordHolder.hourlyData.topAxisValue) * geometry.size.height)
                                .mask(TopRoundedCorner(radius: 2))
                                .animation(.ripple())
                            .gesture(
                                TapGesture()
                                    .onEnded({ _ in
                                        print("Ended, touch is: \(hour.touches)")
                                    })
                            )
                        }
                    }
                }
                Rectangle().frame(width: self.spacing / 2, height: 0)
            }
                .frame(width: geometry.size.width,
                       height: geometry.size.height,
                       alignment: .bottom)
        }
    }
}

struct BarsView_Previews: PreviewProvider {
    
    static var previews: some View {
        BarsView(spacing: 10)
            .environmentObject(UserSettings())
    }
}
