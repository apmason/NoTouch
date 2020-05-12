//
//  ResultsView.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/12/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import SwiftUI

struct ResultsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Touches Today")
            GraphView()
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
