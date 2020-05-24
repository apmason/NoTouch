//
//  YAxisLabel.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/4/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct YAxisLabel: View {
    
    let text: String
    let leadingXOffset: CGFloat
    
    var body: some View {
        Text(text)
            .frame(width: leadingXOffset - 5, height: 40, alignment: .trailing)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .allowsTightening(true)
            .font(.footnote)
    }
}

struct YAxisLabel_Previews: PreviewProvider {
    static var previews: some View {
        YAxisLabel(text: "Test", leadingXOffset: 30)
    }
}
