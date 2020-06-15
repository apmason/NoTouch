//
//  RoundedCorner.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/13/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

/// A shape that is as wide as it's given view, and as tall as the given `radius` parameter. Used to cover a view's corners.
struct CornerCoverer: Shape {
    
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY - (radius))
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY - (radius))
        
        path.move(to: topLeft)
        path.addLine(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addLine(to: topRight)
        
        return path
    }
    
    
}

struct RoundedCorner_Previews: PreviewProvider {
    static var previews: some View {
        CornerCoverer(radius: 5)
            .frame(width: 50, height: 50)
    }
}
