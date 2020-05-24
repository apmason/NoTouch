//
//  BarsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

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
                    ForEach(self.userSettings.recordHolder.touchObservances, id: \.self) { touch in
                        Rectangle()
                            .frame(width: self.rectangleWidth(for: geometry.size.width),
                                   height: touch.ratio(withTopValue: self.userSettings.recordHolder.touchObservances.topAxisValue) * geometry.size.height)
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
