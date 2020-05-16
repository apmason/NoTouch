//
//  NoTouchMacUITests.swift
//  NoTouchMacUITests
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import XCTest

class NoTouchMacUITests: XCTestCase {

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
