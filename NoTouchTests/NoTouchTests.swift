//
//  NoTouchTests.swift
//  NoTouchTests
//
//  Created by Alexander Mason on 3/21/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CoreML
import XCTest
@testable import NoTouch

class NoTouchTests: XCTestCase {

    func testStartingState() throws {
        let modelUpdater = makeModelUpdaterStub()
        XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.notCollecting)
    }
    
    func testNextStateProgression() throws {
        let modelUpdater = makeModelUpdaterStub()
        
        /**
         - Not collecting
         
         - Prime touching
         - Collect touching
         
         - Prime not touching
         - Collect not touching
         
         - ### BACK TO NOT COLLECTING ###
         */
        
        
        XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.notCollecting)
        
        let primingTouching = modelUpdater.collectionState.nextState
        XCTAssertEqual(primingTouching, ModelUpdater.CollectionState.primingTouching)
        
        let collectingTouching = primingTouching.nextState
        XCTAssertEqual(collectingTouching, ModelUpdater.CollectionState.collectingTouching)
        
        let primingNotTouching = collectingTouching.nextState
        XCTAssertEqual(primingNotTouching, ModelUpdater.CollectionState.primingNotTouching)
        
        let collectingNotTouching = primingNotTouching.nextState
        XCTAssertEqual(collectingNotTouching, ModelUpdater.CollectionState.collectingNotTouching)
        
        let notCollecting = collectingNotTouching.nextState
        XCTAssertEqual(notCollecting, ModelUpdater.CollectionState.notCollecting)
    }
    
    // Test the waiting/signalling flow (startCollecting)
    func testStartCollecting() {
        let modelUpdater = makeModelUpdaterStub()
        
        let expectation = XCTestExpectation(description: "ModelUpdater.Collecting")
        
        modelUpdater.startCollecting() // Now at primingTouching (runs for 3 seconds)
        XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.primingTouching)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { // (runs for 10 seconds)
            // Now at collectingTouching
            XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.collectingTouching)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 14) {
            // Now at primingNotTouching
            XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.primingNotTouching)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 24) {
            // Now at collectingNotTouching
            XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.collectingNotTouching)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 27) {
            // Back to start, notCollecting
            XCTAssertEqual(modelUpdater.collectionState, ModelUpdater.CollectionState.notCollecting)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30)
    }
}

extension NoTouchTests {
    
    class StubModelUpdaterDelegate: ModelUpdaterDelegate {
        func startPrimingTouching() {}
        
        func startPrimingNotTouching() {}
        
        func startCollectingTouching() {}
        
        func startCollectingNotTouching() {}
    }
    
    func makeModelUpdaterStub() -> ModelUpdater {
        return ModelUpdater(originalModel: MLModel(), delegate: StubModelUpdaterDelegate())
    }
}
