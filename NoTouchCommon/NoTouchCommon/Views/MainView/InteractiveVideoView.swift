//
//  InteractiveVideoView.swift
//  NoTouch
//
//  Created by Alexander Mason on 4/26/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct InteractiveVideoView: View {
        
    let videoFeed: VideoFeed
    
    /// Tracks whether we should be showing the graph. Passed into the `ResultsView` so it can dismiss itself.
    @State private var showGraph = false
    
    @EnvironmentObject var userSettings: UserSettings
    
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor.edgesIgnoringSafeArea(.all)
            if !userSettings.hideCameraFeed && !userSettings.pauseDetection {
                Text("Loading Video...")
                    .font(Font.defaultFont(size: 14))
                    .foregroundColor(Color.white)
                    .padding(8)
            } else if userSettings.pauseDetection {
                Text("Detection Paused")
                    .font(Font.defaultFont(size: 14))
                    .foregroundColor(Color.white)
                    .padding(8)
            } else if userSettings.hideCameraFeed {
                Text("Video Feed Hidden")
                    .font(Font.defaultFont(size: 14))
                    .foregroundColor(Color.white)
                    .padding(8)
            }
            
            #if os(OSX)
            MacLayerView(videoFeed: self.videoFeed)
            #elseif os(iOS)
            iOSLayerView(videoFeed: self.videoFeed)
                .edgesIgnoringSafeArea(.all)
            #endif
            
            if !showGraph {
                HorizontalButtonArrangement(showGraph: self.$showGraph)
                    .environmentObject(userSettings)
            }
            else {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    ResultsView(showGraph: $showGraph)
                }
                .graphTransition()
            }
        }
    }
    
    private var backgroundColor: Color {
        if userSettings.pauseDetection {
            return .appGreen
        } else if userSettings.hideCameraFeed {
            return .black
        } else {
            return .black
        }
    }
}

private struct GraphTransition: ViewModifier {
    func body(content: Content) -> some View {
        #if os(OSX)
        return content.transition(.opacity)
        #else
        return content.transition(.opacity)
        #endif
    }
}

private extension View {
    func graphTransition() -> some View {
        self.modifier(GraphTransition())
    }
}

struct HorizontalButtonArrangement: View {
    
    @Binding var showGraph: Bool
    @EnvironmentObject var userSettings: UserSettings
    
    #if os(iOS)
    private let buttonHeight: CGFloat = 45
    #else
    private let buttonHeight: CGFloat = 40
    #endif
    
    var body: some View {
        HStack(alignment: .top) {
            OptionButtonStack(buttonHeight: self.buttonHeight) // Stack on the left side.
            
            Spacer()
            
            StateWarningView()
                .environmentObject(userSettings)
            
            Spacer()
            
            GraphButton(showGraph: self.$showGraph, buttonHeight: buttonHeight)
        }
    }
}

struct GraphButton: View {
    
    @Binding var showGraph: Bool
    let buttonHeight: CGFloat
    
    var body: some View {
        Button(action: { // Graph button on the right side.
            withAnimation(.easeInOut(duration: 0.35)) {
                self.showGraph.toggle()
            }
        }) {
            Image("graph", bundle: Bundle(for: VisionModel.self))
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

struct StateWarningView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            
            // if touch detected
            if userSettings.isTouching {
                TouchDetectedView()
            }
            
            if !userSettings.networkTracker.isNetworkAvailable {
                Text("Disconnected From Internet")
                    .fontWeight(.medium)
                    .foregroundColor(Color.red)
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
                    .foregroundColor(Color.red)
                
            } else if userSettings.networkTracker.cloudKitAuthStatus == .restricted {
                Text("Enable iCloud to track how many times you touch your face in a day.")
                    .fontWeight(.medium)
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.3)
                    .allowsTightening(true)
                    .padding(.horizontal, 40)
                    .foregroundColor(Color.red)
            }
        }
        .padding(8)
    }
}

struct InteractiveVideoView_Previews: PreviewProvider {
    
    static var userSettings = UserSettings()
    
    static var previews: some View {
        InteractiveVideoView(videoFeed: VideoFeed(userSettings: userSettings))
            .environmentObject(userSettings)
    }
}
