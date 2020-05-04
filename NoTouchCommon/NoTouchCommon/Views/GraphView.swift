//
//  GraphView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    var width: CGFloat = 300
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                AxisView()
                
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
