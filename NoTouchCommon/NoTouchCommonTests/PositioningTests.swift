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
        var recordHolder = RecordHolder()
        recordHolder.add(TouchRecord(deviceName: "123", timestamp: Date(), version: "123", origin: .database))
        
        let topAxis = recordHolder.axisValue(for: .top)
        XCTAssert(topAxis == 3)
        
        let middleAxis = recordHolder.axisValue(for: .middle)
        XCTAssert(middleAxis == 2)
        
        let bottomAxis = recordHolder.axisValue(for: .bottom)
        XCTAssert(bottomAxis == 1)
    }
    
    func testGraphXLabeling() throws {
        let leadingXOffset: CGFloat = 10
        let contentWidth: CGFloat = 100
        let positioner = Positioner(leadingXOffset: leadingXOffset)
        
        let lineOnePosition = positioner.xAxisLabelOffsetFor(line: 1, contentWidth: contentWidth)
        XCTAssert(lineOnePosition == 32.5)
        
        let lineTwoPosition = positioner.xAxisLabelOffsetFor(line: 2, contentWidth: contentWidth)
        XCTAssert(lineTwoPosition == 55)
        
        let lineThreePosition = positioner.xAxisLabelOffsetFor(line: 3, contentWidth: contentWidth)
        XCTAssert(lineThreePosition == 77.5)
        
        let endToThree = contentWidth - lineThreePosition
        let threeToTwo = lineThreePosition - lineTwoPosition
        XCTAssert(threeToTwo == endToThree)
        
        let twoToOne = lineTwoPosition - lineOnePosition
        XCTAssert(twoToOne == threeToTwo)
        XCTAssert(twoToOne == endToThree)
        
        let oneToStart = lineOnePosition - leadingXOffset
        XCTAssert(oneToStart == twoToOne)
        XCTAssert(oneToStart == threeToTwo)
        XCTAssert(oneToStart == endToThree)
    }
    
    func testBarViewSizing() {
        // Allocate with dummy data
        let spacing: CGFloat = 10
        let barsView = BarsView(selectedBar: .constant(nil), spacing: spacing)
        let rectangleWidth = barsView.rectangleWidth(for: 400)
        XCTAssert(rectangleWidth == 6.666666666666667)
    }
}
