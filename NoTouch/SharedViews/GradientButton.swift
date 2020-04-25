//
//  GradientButton.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
    }
    
    func addGradient() {
        self.layer.cornerRadius = self.bounds.height * 0.5
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
          UIColor(red:0.94, green:0.34, blue:0.34, alpha:1).cgColor,
          UIColor(red:0.82, green:0.11, blue:0.11, alpha:1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.96, y: 0.22)
        gradient.endPoint = CGPoint(x: -0.03, y: 1)
        gradient.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
}
