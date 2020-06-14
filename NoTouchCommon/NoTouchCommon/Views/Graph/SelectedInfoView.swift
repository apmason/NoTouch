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
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("TOTAL")
                .font(.caption)
                .foregroundColor(Color.init(red: 123/255, green: 123/255, blue: 123/255))
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(touchCount)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("touches")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.init(red: 137/255, green: 137/255, blue: 137/255))
            }
            Text(dateText)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundColor(Color.init(red: 123/255, green: 123/255, blue: 123/255))
        }
        .frame(height: 65, alignment: .leading)
        .padding(10)
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    private var touchCount: Int {
        guard let selectedBar = self.selectedBar else {
            return userSettings.recordHolder.totalTouchCount
        }
        
        return selectedBar.hourlyData.touches
    }
    
    private var backgroundColor: Color {
        if selectedBar == nil {
            return Color.clear
        } else {
            return Color.init(red: 241/255, green: 242/255, blue: 246/255)
        }
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
