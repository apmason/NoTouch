//
//  ResultsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/12/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

public struct ResultsView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    private let leadingXOffset: CGFloat = 30
    
    @Binding private var showGraph: Bool
    
    public init(showGraph: Binding<Bool>) {
        self._showGraph = showGraph
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button.init(action: {
                withAnimation {
                    self.showGraph.toggle()
                }
            }) {
                Text("Back")
            }
            .padding(.leading, leadingXOffset)
            
            Text("Touches Today: \(userSettings.recordHolder.totalTouchCount)")
                .font(.headline)
                .padding(.leading, leadingXOffset)
            
            GraphView(leadingXOffset: leadingXOffset)
        }
        .padding(.top, 8)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(showGraph: .constant(true))
            .environmentObject(UserSettings())
    }
}
