//
//  View+if.swift
//  NoTouchCommon
//
//  Created by Alex Mason on 7/7/21.
//  Copyright © 2021 Canopy Interactive. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
}
