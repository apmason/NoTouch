//
//  BarsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct BarsView: View {
    
    @Binding var touchObservances: [Touch]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(self.touchObservances, id: \.self) { touch in
                    Rectangle()
                        .frame(height: touch.ratio(withTopValue: self.touchObservances.topAxisValue()) * geometry.size.height)
                }
            }
            .padding(.horizontal, 5)
        }
    }
}

struct BarsView_Previews: PreviewProvider {
    
    static let dummyData: [Touch] = [
        1, 3, 4, 2, 5, 5,
        2, 3, 34, 4, 3, 4,
        5, 4, 3, 4, 5, 4,
        23, 56, 23, 54, 2
    ]
    
    static var previews: some View {
        BarsView(touchObservances: .constant(dummyData))
    }
}
