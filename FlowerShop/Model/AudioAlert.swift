//
//  AudioAlert.swift
//  FlowerShop
//
//  Created by Alexander Mason on 3/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import AVFoundation
import Foundation

class AudioAlert {
    
    private var player: AVAudioPlayer?
    private let fileName = "ding"
    var isMuted: Bool = false {
        didSet {
            guard isMuted, let player = player, player.isPlaying else {
                return
            }

            player.stop()
        }
    }
    
    init() {
        // setup Audio Session
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension AudioAlert: AlertObserver {
    
    func alertDidFire(withTimeoutPeriod timeoutPeriod: TimeInterval) {
        func playSound() {
            guard let player = player, !isMuted else {
                return
            }
            
            if player.isPlaying {
                player.stop()
            }
            
            player.play(atTime: 0)
        }
    }
}
