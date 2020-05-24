//
//  TouchTests.swift
//  NoTouchCommonTests
//
//  Created by Alexander Mason on 5/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest
@testable import NoTouchCommon

class TouchTests: XCTestCase {

    func testTouchRatio() throws {
        let value: Touch = 2
        let ratio = value.ratio(withTopValue: 4)
        XCTAssert(ratio == 0.5)
        
        let value2: Touch = 4
        let ratio2 = value2.ratio(withTopValue: 4)
        XCTAssert(ratio2 == 1)
        
        let value3: Touch = 1
        let ratio3 = value3.ratio(withTopValue: 10)
        XCTAssert(ratio3 == 0.10)
        
        let value4: Touch = 0
        let ratio4 = value4.ratio(withTopValue: 10)
        XCTAssert(ratio4 == 0)
    }
}
