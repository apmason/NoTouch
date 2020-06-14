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
        if self.selectedBar != nil { // show bar info
            VStack(alignment: .leading) { // Selected item view
                HStack {
                    Text("\(self.selectedBar!.hourlyData.touches)")
                        .font(.headline)
                        .foregroundColor(Color.black)
                    Text("touches")
                        .font(.body)
                        .foregroundColor(Color.white)
                }
                Text("\(self.selectedBar!.hourlyData.index)")
                    .font(.caption)
                Text("+5% vs this hour yesterday")
                    .font(.footnote)
            }
            .padding(10)
            .frame(height: 65)
            .background(Color.black.opacity(0.3))
            .cornerRadius(4)
        }
        else {
            VStack(alignment: .leading, spacing: 3) {
                Text("TOTAL")
                    .font(.caption)
                    .foregroundColor(Color.init(red: 123/255, green: 123/255, blue: 123/255))
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(userSettings.recordHolder.totalTouchCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("touches")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.init(red: 137/255, green: 137/255, blue: 137/255))
                }
                Text("Today")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundColor(Color.init(red: 123/255, green: 123/255, blue: 123/255))
            }
            .frame(height: 65, alignment: .leading)
        }
    }
}

struct SelectedInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedInfoView(selectedBar: .constant(nil))
            .environmentObject(UserSettings())
    }
}
