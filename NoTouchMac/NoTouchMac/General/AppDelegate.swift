//
//  AppDelegate.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Combine
import Cocoa
import SwiftUI
import Foundation
import NoTouchCommon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private var menuBarMuteItem = NSMenuItem(title: "Mute Sound",
                                          action: #selector(AppDelegate.muteSoundTapped(_:)),
                                          keyEquivalent: "m")
    
    private var menuBarVideoItem = NSMenuItem(title: "Hide Video Feed",
                                                  action: #selector(AppDelegate.hideFeedTapped(_:)),
                                                  keyEquivalent: "d")
    
    @IBOutlet weak var dockMuteItem: NSMenuItem!
    @IBOutlet weak var dockVideoItem: NSMenuItem!
    
    public static let userSettings: UserSettings = UserSettings()

    /// A cancellable observation that tracks whether the user has muted sound.
    private var muteObservation: AnyCancellable?
    
    /// A cancellable observation that tracks whether the user has stopped showing video in the view.
    private var videoObservation: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
            .environmentObject(AppDelegate.userSettings)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.delegate = self
        window.aspectRatio = NSSize(width: 480, height: 300)
        window.makeKeyAndOrderFront(nil)
        
        // Add button
        if let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name("mac_menu_icon"))
        }
        
        constructMenu()
        listenForUserSettingsUpdates()
    }

    @IBAction func muteSoundTapped(_ sender: Any) {
        AppDelegate.userSettings.muteSound = !AppDelegate.userSettings.muteSound
    }
    
    @IBAction func hideFeedTapped(_ sender: Any) {
        AppDelegate.userSettings.hideCameraFeed = !AppDelegate.userSettings.hideCameraFeed
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        menuBarMuteItem.state = .off
        menuBarVideoItem.state = .off
        
        menu.addItem(menuBarMuteItem)
        menu.addItem(menuBarVideoItem)
        
        statusItem.menu = menu
    }
    
    private func listenForUserSettingsUpdates() {
        muteObservation = AppDelegate.userSettings.$muteSound.sink(receiveValue: { muteSound in
            self.menuBarMuteItem.state = muteSound ? .on : .off
            self.dockMuteItem.state = self.menuBarMuteItem.state
        })
        
        videoObservation = AppDelegate.userSettings.$hideCameraFeed.sink(receiveValue: { hideFeed in
            self.menuBarVideoItem.state = hideFeed ? .on : .off
            self.dockVideoItem.state = self.menuBarVideoItem.state
        })
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        let dataDict: [String: Any] = [
            "height": frameSize.height,
            "width": frameSize.width
        ]
        
        NotificationCenter.default.post(name: .windowWillResize, object: nil, userInfo: dataDict)
        return frameSize
    }
}

