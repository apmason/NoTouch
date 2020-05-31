//
//  MainScreenView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/24/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

public struct MainScreenView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    let contentViewModel: ContentViewModel
    
    public init(contentViewModel: ContentViewModel) {
        self.contentViewModel = contentViewModel
    }
    
    @ViewBuilder
    public var body: some View {
        if userSettings.cameraAuthState == .authorized || userSettings.cameraAuthState == .notDetermined {
            InteractiveVideoView(videoFeed: self.contentViewModel.feed)
        } else {
            #if os(OSX)
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
            #else
            iOSCameraAuthView()
            #endif
        }
    }
}

struct MainScreenView_Previews: PreviewProvider {
    
    static let userSettings = UserSettings()
    static let alertViewModel = AlertViewModel(userSettings: userSettings, database: CloudKitDatabase())
    
    static func mockUserSettings() -> UserSettings {
        let userSettings = UserSettings()
        userSettings.cameraAuthState = .denied
        return userSettings
    }
    
    static var previews: some View {
        MainScreenView(contentViewModel: ContentViewModel(alertModel: alertViewModel,
                                                          userSettings: mockUserSettings()))
            .environmentObject(userSettings)
    }
}
