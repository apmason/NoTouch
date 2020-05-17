//
//  InteractiveVideoView.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/26/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import NoTouchCommon
import SwiftUI

struct InteractiveVideoView: View {
    
    let buttonHeight: CGFloat = 40
    
    let videoFeed: VideoFeed
    
    /// Tracks whether we should be showing the graph. Passed into the `ResultsView` so it can dismiss itself.
    @State private var showGraph = false
    
    @EnvironmentObject var userSettings: UserSettings
    
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .top) {
            VideoLayerView(videoFeed: self.videoFeed) // always on bottom.
            
            if !showGraph {
                HStack(alignment: .top) {
                    OptionButtonStack() // Stack on the left side.
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        if !userSettings.networkTracker.isNetworkAvailable {
                            Text("Disconnected From Internet")
                                .fontWeight(.medium)
                        }
                        
                        if userSettings.networkTracker.cloudKitAuthStatus == .signedOut {
                            Text("Sign in to iCloud to track how many times you touch your face in a day and see your progress improve!")
                                .fontWeight(.medium)
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.3)
                                .allowsTightening(true)
                                .padding(.horizontal, 40)
                            
                        } else if userSettings.networkTracker.cloudKitAuthStatus == .restricted {
                            Text("Enable iCloud to track how many times you touch your face in a day.")
                                .fontWeight(.medium)
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.3)
                                .allowsTightening(true)
                                .padding(.horizontal, 40)
                        }
                        
                    }.padding(.top, 8)
                    
                    Spacer()
                    
                    Button(action: { // Graph button on the right side.
                        withAnimation {
                            self.showGraph.toggle()
                        }
                    }) {
                        Image("graph")
                            .resizable()
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: buttonHeight, height: buttonHeight, alignment: .top)
                    .padding(8)
                }
            }
            else {
                ResultsView(showGraph: $showGraph)
            }
        }
    }
}

struct InteractiveVideoView_Previews: PreviewProvider {
    
    static var userSettings = UserSettings()
    
    static var previews: some View {
        InteractiveVideoView(videoFeed: VideoFeed(userSettings: userSettings))
            .environmentObject(userSettings)
    }
}
