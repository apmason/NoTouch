//
//  RoundedCorner.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 6/13/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct TopRoundedCorner: Shape {
    
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tls = CGPoint(x: rect.minX + radius, y: rect.minY)
        let tlc = CGPoint(x: rect.minX + radius, y: rect.minY + radius)
        
        let trc = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)
        let trs = CGPoint(x: rect.maxX, y: rect.minY + radius)
        
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        
        // cover bottom
        path.move(to: bl)
        path.addLine(to: br)
        
        // draw top right curve
        path.addLine(to: trs)
        path.addRelativeArc(center: trc, radius: radius, startAngle: Angle.degrees(0), delta: Angle.degrees(-90))
        
        // draw top left curve
        path.addLine(to: tls)
        
        
        path.addRelativeArc(center: tlc, radius: radius, startAngle: Angle.degrees(0), delta: Angle.degrees(-180))
        
        return path
    }
    
    
}

struct RoundedCorner_Previews: PreviewProvider {
    static var previews: some View {
        TopRoundedCorner(radius: 5)
            .frame(width: 50, height: 50)
    }
}
