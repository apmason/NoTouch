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
    
    private var muteMenuItem = NSMenuItem(title: "Mute Sound",
                                          action: #selector(AppDelegate.muteSound(_:)),
                                          keyEquivalent: "m")

    private var hideCameraFeedItem = NSMenuItem(title: "Hide Video Feed",
                                                  action: #selector(AppDelegate.hideCameraFeed(_:)),
                                                  keyEquivalent: "d")

    public static let userSettings: UserSettings = UserSettings()

    private var muteObservation: AnyCancellable?
    
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

    @objc func muteSound(_ sender: Any?) {
        AppDelegate.userSettings.muteSound = !AppDelegate.userSettings.muteSound
        muteMenuItem.state = AppDelegate.userSettings.muteSound ? .on : .off
    }
    
    @objc func hideCameraFeed(_ sender: Any?) {
        AppDelegate.userSettings.hideCameraFeed = !AppDelegate.userSettings.hideCameraFeed
        hideCameraFeedItem.state = AppDelegate.userSettings.hideCameraFeed ? .on : .off
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        muteMenuItem.state = .off
        hideCameraFeedItem.state = .off
        
        menu.addItem(muteMenuItem)
        menu.addItem(hideCameraFeedItem)
        
        statusItem.menu = menu
    }
    
    private func listenForUserSettingsUpdates() {
        muteObservation = AppDelegate.userSettings.$muteSound.sink(receiveValue: { muteSound in
            self.muteMenuItem.state = muteSound ? .on : .off
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

