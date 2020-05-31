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
        MainScreenView(contentViewModel: contentViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let userSettings = UserSettings()
    static let alertViewModel = AlertViewModel(userSettings: userSettings, database: CloudKitDatabase())
    
    static var previews: some View {
        ContentView(contentViewModel: ContentViewModel(alertModel: alertViewModel,
                                                       userSettings: userSettings))
            .environmentObject(userSettings)
    }
}
