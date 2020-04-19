//
//  ContentView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI
import NoTouchCommon

struct ContentView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    let contentViewModel = ContentViewModel()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VideoLayerView(inputtingTo: contentViewModel.feed)
            Button(action: {
                self.userSettings.muteSound.toggle()
            }) {
                Image(userSettings.muteSound ? "speaker.slash" : "speaker")
                    .resizable()
                    .padding(8)
                    .foregroundColor(Color.white)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 40, height: 40, alignment: .topLeading)
            .padding(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
}
