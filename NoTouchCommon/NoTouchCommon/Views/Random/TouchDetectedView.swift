//
//  TouchDetectedView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/7/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct TouchDetectedView: View {
    
    // Determine if we are in light mode or dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("Touch Detected!")
            .font(.subheadline)
            .padding(18)
            .foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
            .cornerRadius(10)
    }
}

struct TouchDetectedView_Previews: PreviewProvider {
    static var previews: some View {
        TouchDetectedView()
    }
}
