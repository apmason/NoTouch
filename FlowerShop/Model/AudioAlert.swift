//
//  AudioAlert.swift
//  FlowerShop
//
//  Created by Alexander Mason on 3/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import AVFoundation
import Foundation

class AudioAlert: NSObject {
    
    private var player: AVAudioPlayer?
    private let fileName = "beep-01a"
    var isMuted: Bool = false {
        didSet {
            guard isMuted, let player = player, player.isPlaying else {
                return
            }

            player.stop()
        }
    }
    
    override init() {
        super.init()
        
        // setup Audio Session
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.prepareToPlay()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension AudioAlert: AlertObserver {
    
    func startAlerting() {
        guard let player = player, !isMuted else {
            return
        }
        
        guard !player.isPlaying else {
            return
        }
        
        player.play()
    }
    
    func stopAlerting() {
        player?.stop()
        player?.currentTime = 0
        player?.prepareToPlay()
    }
}

extension AudioAlert: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing succesfully: \(flag)")
    }
}


