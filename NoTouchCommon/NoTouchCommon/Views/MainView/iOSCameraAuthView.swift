//
//  iOSCameraAuthView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/24/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

#if os(iOS)
import SwiftUI

struct iOSCameraAuthView: View {
    var body: some View {
        VStack {
            Text("Camera permissions are required to use NoTouch!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button.init(action: {
                self.openSettingsURL()
            }) {
                Text("Update Camera Permissions")
            }
        }
        .padding()
    }
    
    func openSettingsURL() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url,
                                  options: [:],
                                  completionHandler: nil)
    }
}

struct iOSCameraAuthView_Previews: PreviewProvider {
    static var previews: some View {
        iOSCameraAuthView()
    }
}
#endif
