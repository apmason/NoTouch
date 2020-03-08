//
//  TutorialViewModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewModel: TutorialProvider {
    
    weak var delegate: TutorialProviderDelegate?
    
    func createViews() -> [UIView] {
        guard let firstPage: FirstIntroView = Bundle.main.loadNibNamed("FirstIntroView", owner: nil, options: nil)?.first as? FirstIntroView else {
            assertionFailure("Failure getting first page")
            return []
        }
        
        let slideViews = createSlideViews()
        // Listen for final button taps
        slideViews.last?.button.isHidden = false
        slideViews.last?.delegate = self
        
        var slides: [UIView] = slideViews
        slides.insert(firstPage, at: 0)
        
        return slides
    }
}

extension TutorialViewModel: SlideViewDelegate {
    
    func buttonTapped() {
        print("Button was tapped, what to do?")
        delegate?.presentVisionScreen()
    }
}
