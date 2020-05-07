//
//  BarsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/5/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct BarsView: View {
    
    var touchData: [TouchRecord] = []
    
    var body: some View {
        HStack {
            Text("Test")
        }
    }
}

struct BarsView_Previews: PreviewProvider {
    static var previews: some View {
        BarsView()
    }
}
