//
//  VideoView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/11/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct VideoView: View {
    var body: some View {
        ZStack {
            Button(action: {
                // toggle sound
            }) {
                Image("speaker")
            }
            VideoLayerView()
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
