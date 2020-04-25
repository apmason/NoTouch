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
        
    //let contentViewModel = ContentViewModel()
    private var cameraImageAspectRatio: CGFloat {
        let image = NSImage(named: "camera")!
        let aspect = image.size.width / image.size.height
        return aspect
    }
    
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
                .frame(width: 50, height: 50)
                .padding(10)
                
                Button(action: {
                    self.userSettings.hideCameraFeed.toggle()
                }) {
                    Image(userSettings.hideCameraFeed ? "eye.slash" : "eye")
                        .resizable()
                        .padding(4)
                        .foregroundColor(Color.white)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 50, height: 50, alignment: .center)
                .padding(10)
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
