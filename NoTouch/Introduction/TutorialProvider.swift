//
//  TutorialProvider.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

protocol TutorialProvider {
    func createViews() -> [UIView]
}

extension TutorialProvider {
    
    func createSlideViews() -> [SlideView] {
        var slideViews = [SlideView]()
        
        for i in 0...5 {
            guard let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: nil, options: nil)?.first as? SlideView else {
                assertionFailure("Failure")
                return []
            }
            
            switch i {
            case 0:
                slide.textLabel.text = placingText
                
            case 1:
                slide.textLabel.text = moveCloserText
                
            case 2:
                slide.textLabel.text = alertText
                
            case 3:
                slide.textLabel.text = openText
                
            case 4:
                slide.textLabel.text = batteryText
                
            case 5:
                slide.textLabel.text = privacyText
                slide.showButton = true
                slide.button.isHidden = false
                
            default:
                print("REACHED DEFAULT, SOMETHING WENT WRONG")
                assertionFailure("Default hit")
            }
            
            slideViews.append(slide)
        }
        
        return slideViews
    }
}

fileprivate var placingText: String {
    return NSLocalizedString("Place your device in front of you so your face is in the middle of the camera's frame.", comment: "Placing description")
}

fileprivate var moveCloserText: String {
    return NSLocalizedString("Move the device closer to your face for the best results.", comment: "Best results description")
}

fileprivate var alertText: String {
    return NSLocalizedString("When you touch your face you'll be alerted.", comment: "Alert functionality description")
}

fileprivate var openText: String {
    return NSLocalizedString("NoTouch and your device will need to be open to work.", comment: "Open description")
}

fileprivate var batteryText: String {
    return NSLocalizedString("Plug your device in if possible.", comment: "Battery usage description")
}

fileprivate var privacyText: String {
    return NSLocalizedString("Privacy comes first.\n\nNone of your data is saved.\n\nNoTouch works with no Internet.", comment: "Privacy description")
}
