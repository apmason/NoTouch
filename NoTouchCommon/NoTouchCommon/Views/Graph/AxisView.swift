//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct AxisView: View {
    
    let lineWidth: CGFloat
    let leadingXOffset: CGFloat
    let bottomYOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Y Axis
                // bottom left corner
                path.move(to:
                    CGPoint(x: self.leadingXOffset,
                            y: geometry.size.height - self.bottomYOffset)
                )
                // straight up
                path.addLine(to:
                    CGPoint(x: self.leadingXOffset,
                            y: 0)
                )
                
                // X Axis
                // bottom left corner
                path.move(to:
                    CGPoint(x: self.leadingXOffset + (self.lineWidth / 2),
                            y: geometry.size.height - (self.lineWidth / 2) - self.bottomYOffset)
                )
                // To the left
                path.addLine(to:
                    CGPoint(x: geometry.size.width,
                            y: geometry.size.height - (self.lineWidth / 2) - self.bottomYOffset)
                )
                
                // Line going across the top of graph
                path.move(to:
                    CGPoint(x: self.leadingXOffset,
                            y: 0)
                )
                
                path.addLine(to:
                    CGPoint(x: geometry.size.width,
                            y: 0)
                )
            }
            .stroke(Color.black, lineWidth: self.lineWidth * 2)
        }
    }
}

struct AxisView_Previews: PreviewProvider {
    static var previews: some View {
        AxisView(lineWidth: 1,
                 leadingXOffset: 20,
                 bottomYOffset: 20)
    }
}
