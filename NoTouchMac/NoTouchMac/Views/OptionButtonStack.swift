//
//  OptionButtonStack.swift
//  HandsOff
//
//  Created by Alexander Mason on 5/7/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import NoTouchCommon
import SwiftUI

struct OptionButtonStack: View {
    
    @EnvironmentObject var userSettings: UserSettings
    private let buttonHeight: CGFloat = 40
    
    var body: some View {
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

struct OptionButtonStack_Previews: PreviewProvider {
    static var previews: some View {
        OptionButtonStack()
            .environmentObject(UserSettings())
    }
}
