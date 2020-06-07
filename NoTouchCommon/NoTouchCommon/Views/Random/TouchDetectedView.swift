//
//  TouchDetectedView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/7/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct TouchDetectedView: View {
    var body: some View {
        Text("Touch Detected!")
            .font(.subheadline)
            .padding()
            .foregroundColor(.white)
            .background(
                Rectangle()
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(10)
        )
    }
}

struct TouchDetectedView_Previews: PreviewProvider {
    static var previews: some View {
        TouchDetectedView()
    }
}
