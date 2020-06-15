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
    
    // Determine if we are in light mode or dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                Button.init(action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.showGraph.toggle()
                    }
                }) {
                    Text("Back")
                }
                .padding(.leading, self.leadingXOffset)
                
//                HStack {
//                    HStack(spacing: 10) {
//                        
//                        
//                        Text("Touches Today: \(self.userSettings.recordHolder.totalTouchCount)")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .padding(.trailing, 8)
//                    }
//                    
//                    Spacer()
//                    
//                    VStack(alignment: .trailing, spacing: 10) {
//                        if !self.userSettings.networkTracker.isNetworkAvailable {
//                            Text("No Internet")
//                                .font(.caption)
//                                .foregroundColor(Color.red)
//                        }
//                        
//                        if self.userSettings.networkTracker.cloudKitAuthStatus == .signedOut || self.userSettings.networkTracker.cloudKitAuthStatus == .restricted {
//                            Text("iCloud Disabled")
//                                .font(.caption)
//                                .foregroundColor(Color.red)
//                        }
//                    }.padding(.trailing, 10)
//                }
                
                GraphView(leadingXOffset: self.leadingXOffset)
            }
            .edgePadding(topInsets: geometry.safeAreaInsets.top, bottomInsets: geometry.safeAreaInsets.bottom)
            .padding(.leading, geometry.safeAreaInsets.leading)
            .padding(.trailing, geometry.safeAreaInsets.trailing)
            .background(self.colorScheme == .dark ? Color(.sRGB, red: 46/255, green: 47/255, blue: 48/255, opacity: 1.0) : Color.white)
        }
    }
}

private struct MacPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content.padding(.top, 8)
    }
}

private struct iOSPadding: ViewModifier {
    let topInsets: CGFloat
    let bottomInsets: CGFloat
    
    func body(content: Content) -> some View {
        content.padding(.top, max(14, topInsets)).padding(.bottom, bottomInsets)
    }
}

private extension View {
    func edgePadding(topInsets: CGFloat, bottomInsets: CGFloat) -> some View {
        #if os(OSX)
        return self.modifier(MacPadding())
        #else
        return self.modifier(iOSPadding(topInsets: topInsets, bottomInsets: bottomInsets))
        #endif
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(showGraph: .constant(true))
            .environmentObject(UserSettings())
    }
}
