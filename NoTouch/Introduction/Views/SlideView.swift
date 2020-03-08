//
//  SlideView.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

protocol SlideViewDelegate: class {
    func buttonTapped()
}

class SlideView: UIView {

    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var button: UIButton!
    
    var showButton = false
    
    weak var delegate: SlideViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if showButton {
            colorView()
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped()
    }
    
    func colorView() {
        button.layer.cornerRadius = button.bounds.height * 0.5
        let gradient = CAGradientLayer()
        gradient.frame = button.bounds
        gradient.colors = [
          UIColor(red:0.94, green:0.34, blue:0.34, alpha:1).cgColor,
          UIColor(red:0.82, green:0.11, blue:0.11, alpha:1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.96, y: 0.22)
        gradient.endPoint = CGPoint(x: -0.03, y: 1)
        gradient.cornerRadius = button.layer.cornerRadius
        button.layer.insertSublayer(gradient, at: 0)
    }
}
