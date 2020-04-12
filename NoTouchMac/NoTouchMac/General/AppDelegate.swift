//
//  AppDelegate.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Cocoa
import SwiftUI
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

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
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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

