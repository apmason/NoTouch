//
//  CameraUIView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AVFoundation
import SwiftUI

struct CameraUIView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CameraUIView_Previews: PreviewProvider {
    static var previews: some View {
        CameraUIView()
    }
}

// Feed the video data into a layer.
// Pass in a layer to the video feed to be updated
// Get the layer from an NSView or UIView (need to test this)
// Make a XXView representable struct.
// Pass that to a SwiftUI view.
