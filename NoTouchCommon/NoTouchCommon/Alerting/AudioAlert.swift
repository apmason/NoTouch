//
//  AudioAlert.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import AVFoundation
import Foundation

class AudioAlert: NSObject {
    
    private var player: AVAudioPlayer?
    private let fileName = "beep-offic"
    
    private var audioEngine = AVAudioEngine()
    
    // TODO: On iOS we should setup an audio session
    
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
        guard let url = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "m4a") else {
            fatalError("No audio file")
        }

        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            
        } catch {
            assertionFailure("Error creating audio player: \(error.localizedDescription)")
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
