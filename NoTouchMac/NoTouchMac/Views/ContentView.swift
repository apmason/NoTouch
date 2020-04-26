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
        
    private let buttonHeight: CGFloat = 40
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VideoLayerView()
            VStack {
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
                .frame(width: buttonHeight, height: buttonHeight)
                .padding(8)
                
                Button(action: {
                    self.userSettings.hideCameraFeed.toggle()
                }) {
                    Image(userSettings.hideCameraFeed ? "eye.slash" : "eye")
                        .resizable()
                        .padding(5)
                        .foregroundColor(Color.white)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: buttonHeight, height: buttonHeight)
                .padding(8)
                
                Button(action: {
                    self.userSettings.pauseDetection.toggle()
                }) {
                    Image(userSettings.pauseDetection ? "play" : "pause")
                        .resizable()
                        .padding(7.5)
                        .foregroundColor(Color.white)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: buttonHeight, height: buttonHeight)
                .padding(8)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
}
