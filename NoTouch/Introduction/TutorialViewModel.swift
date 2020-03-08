//
//  TutorialViewModel.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

class TutorialViewModel {
    
    var placingText: String {
        return NSLocalizedString("Place your device in front of you so your face is in the middle of the camera's frame.", comment: "Placing description")
    }
    
    var moveCloserText: String {
        return NSLocalizedString("Move the device closer to your face for the best results.", comment: "Best results description")
    }
    
    var alertText: String {
        return NSLocalizedString("When you touch your face you'll be alerted.", comment: "Alert functionality description")
    }
    
    var openText: String {
        return NSLocalizedString("NoTouch and your device will need to be open to work.", comment: "Open description")
    }
    
    var batteryText: String {
        return NSLocalizedString("Plug your device in if possible.", comment: "Battery usage description")
    }
    
    var privacyText: String {
        return NSLocalizedString("Privacy comes first.\n\nNone of your data is saved.\n\nNoTouch works with no Internet.", comment: "Privacy description")
    }
}
