//
//  TimeLinesView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct TimeLinesView: View {
    
    var numberOfLines: Int
    var bottomOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for line in 1...self.numberOfLines {
                    path.move(to:
                        CGPoint(x: CGFloat(line) * (geometry.size.width / CGFloat(self.numberOfLines + 1)),
                                y: geometry.size.height - self.bottomOffset)
                    )
                    
                    path.addLine(to:
                        CGPoint(x: CGFloat(line) * (geometry.size.width / CGFloat(self.numberOfLines + 1)),
                                y: 0)
                    )
                }
            }
            .stroke(Color.black, lineWidth: 2)
        }
    }
}

struct TimeLinesView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLinesView(numberOfLines: 4, bottomOffset: 2)
            .frame(width: 300, height: 300)
    }
}
