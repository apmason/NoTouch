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
        
    var isMuted: Bool = false {
        didSet {
            if !isMuted, shouldBeAlerting {
                // ask to play?
                startAlerting()
                return
            }
            
            guard isMuted, let player = player, player.isPlaying else {
                return
            }

            player.stop()
        }
    }
    
    private var shouldBeAlerting: Bool = false
    
    override init() {
        super.init()
        
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.allowBluetooth, .mixWithOthers])
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting category: \(error.localizedDescription)")
        }
        #endif
        
        guard let url = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "m4a") else {
            fatalError("No audio file")
        }

        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            player?.delegate = self
            player?.numberOfLoops = -1 // infinite loop
            player?.prepareToPlay()
            
        } catch {
            assertionFailure("Error creating audio player: \(error.localizedDescription)")
        }
    }
}

extension AudioAlert: AlertObserver {
    
    func startAlerting() {
        shouldBeAlerting = true
        guard let player = player, !isMuted else {
            return
        }
        
        guard !player.isPlaying else {
            return
        }
        
        #if os(OSX) // NOTE: Caught a bug during development that required this. It may not be needed now if something underlying was fixed.
        player.stop()
        player.prepareToPlay()
        #endif
        
        player.play()
    }
    
    func stopAlerting() {
        shouldBeAlerting = false
        player?.stop()
        player?.currentTime = 0
        player?.prepareToPlay()
    }
}

extension AudioAlert: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing succesfully: \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decoding error: \(error?.localizedDescription ?? "")")
    }
}
