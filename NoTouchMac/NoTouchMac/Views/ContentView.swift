//
//  ContentView.swift
//  HandsOff
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI
import NoTouchCommon

struct ContentView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    let contentViewModel: ContentViewModel
    
    @ViewBuilder
    var body: some View {
        if userSettings.cameraAuthState == .authorized || userSettings.cameraAuthState == .notDetermined {
            InteractiveVideoView(videoFeed: self.contentViewModel.feed)
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
    
    static let userSettings = UserSettings()
    static let alertViewModel = AlertViewModel(userSettings: userSettings, database: CloudKitDatabase())
    
    static var previews: some View {
        ContentView(contentViewModel: ContentViewModel(alertModel: alertViewModel))
            .environmentObject(userSettings)
    }
}
