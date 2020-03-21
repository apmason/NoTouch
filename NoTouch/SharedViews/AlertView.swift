//
//  AlertView.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/13/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import UIKit

class AlertView: UIView {

    @IBAction func goToSettings(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
