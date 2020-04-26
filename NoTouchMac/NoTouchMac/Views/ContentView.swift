//
//  ContentView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AppKit
import SwiftUI
import NoTouchCommon

struct ContentView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @ViewBuilder
    var body: some View {
        if userSettings.cameraAuthState == .authorized || userSettings.cameraAuthState == .notDetermined {
            InteractiveVideoView()
        } else {
            VStack {
                Text("Please authorize camera usage to continue.")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Text("Go to System Preferences -> Security & Privacy -> Privacy -> Camera and authorize HandsOff.")
                    .font(.body)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
}
