//
//  ResultsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/12/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct ResultsView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    private let leadingXOffset: CGFloat = 30
    
    @Binding var showGraph: Bool
    
    var body: some View {
        GeometryReader { geometry in
            #if os(OSX)
            GraphContent(showGraph: self.$showGraph, leadingXOffset: self.leadingXOffset)
                .environmentObject(self.userSettings)
                //.padding(.top, 8)
            #elseif os(iOS)
            GraphContent(showGraph: self.$showGraph, leadingXOffset: self.leadingXOffset)
                .environmentObject(self.userSettings)
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
            #endif
        }
    }
}

private struct GraphContent: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @Binding var showGraph: Bool
    
    let leadingXOffset: CGFloat
    
    // Determine if we are in light mode or dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Button.init(action: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            self.showGraph.toggle()
                        }
                    }) {
                        Text("Back")
                    }
                    .padding(.leading, self.leadingXOffset)
                    
                    Text("Touches Today: \(self.userSettings.recordHolder.totalTouchCount)")
                        .font(.headline)
                        .padding(.leading, self.leadingXOffset)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    if !self.userSettings.networkTracker.isNetworkAvailable {
                        Text("No Internet")
                            .font(.caption)
                            .foregroundColor(Color.red)
                    }
                    
                    if self.userSettings.networkTracker.cloudKitAuthStatus == .signedOut || self.userSettings.networkTracker.cloudKitAuthStatus == .restricted {
                        Text("iCloud Disabled")
                            .font(.caption)
                            .foregroundColor(Color.red)
                    }
                }.padding(.trailing, 10)
            }
            
            GraphView(leadingXOffset: self.leadingXOffset)
        }
        .background(self.colorScheme == .dark ? Color(.sRGB, red: 46/255, green: 47/255, blue: 48/255, opacity: 1.0) : Color.white)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(showGraph: .constant(true))
            .environmentObject(UserSettings())
    }
}
