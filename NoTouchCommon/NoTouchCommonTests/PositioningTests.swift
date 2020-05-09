//
//  PositioningTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/9/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest

@testable import NoTouchCommon
class PositioningTests: XCTestCase {

    func testGraphYLabeling() throws {
        let topValue = 200
        let view = GraphYLabels(positioner: Positioner(), highestYValue: topValue)
        
        let topAxis = view.valueForYLabel(for: .top)
        XCTAssert(topValue == topAxis)
        
        let middleAxis = view.valueForYLabel(for: .middle)
        XCTAssert(middleAxis == 132)
        
        let bottomAxis = view.valueForYLabel(for: .bottom)
        XCTAssert(bottomAxis == 66)
    }
}
