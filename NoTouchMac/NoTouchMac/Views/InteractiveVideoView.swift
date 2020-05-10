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
    let alertViewModel = AlertViewModel(userSettings: AppDelegate.userSettings)
    let thing = DBManager()
    
    var body: some View {
        ZStack(alignment: .top) {
            VideoLayerView(alertModel: self.alertViewModel)
            HStack(alignment: .top) {
                OptionButtonStack()
                Spacer()
                NavigationLink.init(destination: GraphView(recordHolder: thing.recordHolder)) {
                    Button(action: {
                        // open new thing
                        print("toggle")
                        // navigation link, pass user data.
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
        }
    }
}

struct InteractiveVideoView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveVideoView()
            .environmentObject(UserSettings())
    }
}
