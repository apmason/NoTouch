//
//  AxisView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct AxisView: View {
    
    /// The offset of the y axi
    private var yAxisOffset: CGFloat = 30
    
    private var lineWidth: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical line
            ZStack {
                Path { path in
                    // Y Axis
                    // bottom left corner
                    path.move(to:
                        CGPoint(x: self.lineWidth,
                                y: geometry.size.height - self.yAxisOffset)
                    )
                    // straight up
                    path.addLine(to:
                        CGPoint(x: self.lineWidth,
                                y: 0)
                    )
                    
                    // X Axis
                    // bottom left corner
                    path.move(to:
                        CGPoint(x: 0,
                                y: geometry.size.height - (self.lineWidth / 2) - self.yAxisOffset)
                    )
                    // To the left
                    path.addLine(to:
                        CGPoint(x: geometry.size.width,
                                y: geometry.size.height - (self.lineWidth / 2) - self.yAxisOffset)
                    )
                }
                .stroke(Color.blue, lineWidth: 5)
                
                TimeLinesView(numberOfLines: 4,
                              bottomOffset: self.yAxisOffset + self.lineWidth * 1.5)
                
                Text("Ass")
                    .frame(width: 40, height: 40)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}

struct AxisView_Previews: PreviewProvider {
    static var previews: some View {
        AxisView()
    }
}
