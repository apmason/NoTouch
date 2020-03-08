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
    
    weak var delegate: SlideViewDelegate?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped()
    }
}
