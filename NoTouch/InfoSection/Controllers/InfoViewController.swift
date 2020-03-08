//
//  InfoViewController.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set version label
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            versionLabel.text = ""
            return
        }
        versionLabel.text = "v\(appVersion)"
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareNoTouch(_ sender: UIButton) {
        // Present share screen.
        
        guard let url = URL(string: "https://itunes.apple.com/app/id1502029445") else {
            return
        }
        
        let items = [url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}
