//
//  BarInfoView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/14/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct SelectedInfoView: View {
    
    @Binding var selectedBar: SelectedBar?
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("TOTAL")
                .font(.caption)
                .foregroundColor(thinAccentColor)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(touchCount)")
                    .foregroundColor(touchTextColor)
                    .font(.title)
                    .fontWeight(.bold)
                Text("touches")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(touchesAccentTextColor)
            }
            Text(dateText)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundColor(thinAccentColor)
        }
    }
    
    private var touchTextColor: Color {
        if colorScheme == .dark {
            return selectedBar == nil ? Color.white : Color.black
        }
        else {
            return Color.black
        }
    }
    
    private var thinAccentColor: Color {
        if colorScheme == .dark && selectedBar == nil {
            return Color(red: 170/255, green: 170/255, blue: 170/255)
        } else {
            return Color(red: 123/255, green: 123/255, blue: 123/255)
        }
    }
    
    private var touchesAccentTextColor: Color {
        if colorScheme == .dark && selectedBar == nil {
            return Color(red: 184/255, green: 184/255, blue: 184/255)
        } else {
            return Color(red: 137/255, green: 137/255, blue: 137/255)
        }
    }
    
    private var touchCount: Int {
        guard let selectedBar = self.selectedBar else {
            return userSettings.recordHolder.totalTouchCount
        }
        
        return selectedBar.hourlyData.touches
    }
    
    private var dateText: String {
        guard let selectedBar = self.selectedBar else {
            return "Today"
        }
        
        return selectedBar.hourlyData.dateText
    }
}

struct SelectedInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedInfoView(selectedBar: .constant(nil))
            .environmentObject(UserSettings())
    }
}
