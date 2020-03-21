//
//  InfoTutorialProvider.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation
import UIKit

class InfoTutorialProvider: TutorialProvider {
    weak var delegate: TutorialProviderDelegate?
    
    func createViews() -> [UIView] {
        return self.createSlideViews()
    }
}
