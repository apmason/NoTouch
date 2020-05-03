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
        VStack {
            AxisView()
            // Times
            
//            path.move(to:
//                CGPoint(x: CGFloat(line) * (geometry.size.width / CGFloat(self.numberOfLines + 1)),
//                        y: geometry.size.height - self.bottomOffset)
//            )
            Text("6am")
                .frame(width: 40, height: 40)
//                .position( CGPoint(x: (self.width / 5), y: 245))
        }
        .frame(width: self.width, height: 300)
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
