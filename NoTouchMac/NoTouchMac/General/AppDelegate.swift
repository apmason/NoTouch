//
//  AppDelegate.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Combine
import Cocoa
import SwiftUI
import Foundation
import NoTouchCommon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    // MARK: - Menu Bar Items
    
    private var menuBarMuteItem = NSMenuItem(title: "Mute Sound",
                                             action: #selector(AppDelegate.muteSoundTapped(_:)),
                                             keyEquivalent: "m")
    private var menuBarVideoItem = NSMenuItem(title: "Hide Video Feed",
                                              action: #selector(AppDelegate.hideFeedTapped(_:)),
                                              keyEquivalent: "d")
    private var menuBarPauseItem = NSMenuItem(title: "Pause Detection",
                                              action: #selector(AppDelegate.pauseTapped(_:)),
                                              keyEquivalent: "p")
    
    // MARK: - Dock Menu Items
    
    @IBOutlet weak var dockMuteItem: NSMenuItem!
    @IBOutlet weak var dockVideoItem: NSMenuItem!
    @IBOutlet weak var dockPauseItem: NSMenuItem!
    
    // MARK: - Main Menu items
    
    @IBOutlet weak var mainMenuMuteItem: NSMenuItem!
    @IBOutlet weak var mainMenuVideoItem: NSMenuItem!
    @IBOutlet weak var mainMenuPauseItem: NSMenuItem!
    
    public static let userSettings: UserSettings = UserSettings()
    
    /// Manages the CloudKit database that populates our historical data.
    //private var ckManager: CloudKitManager = CloudKitManager()

    /// A cancellable observation that tracks whether the user has muted sound.
    private var muteObservation: AnyCancellable?
    
    /// A cancellable observation that tracks whether the user has stopped showing video in the view.
    private var videoObservation: AnyCancellable?
    
    /// A cancellable observation that tracks whether we should stop or start recording.
    private var pauseObservation: AnyCancellable?
    
    private let alertViewModel = AlertViewModel(userSettings: AppDelegate.userSettings)
    
    private var contentViewModel: ContentViewModel!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.contentViewModel = ContentViewModel(alertModel: alertViewModel)
        setCameraAuthState()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(contentViewModel: contentViewModel)
            .environmentObject(AppDelegate.userSettings)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.delegate = self
        window.aspectRatio = NSSize(width: 480, height: 300)
        window.minSize = NSSize(width: 300, height: 187.5)
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        // Add button
        if let button = statusItem.button {
          button.image = NSImage(named: NSImage.Name("mac_menu_icon"))
        }
        
        constructMenu()
        listenForUserSettingsUpdates()
        
        // Used for silent push notifications for CloudKit updates.
        NSApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        guard let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKDatabaseNotification else {
                return
        }
        
        //ckManager.fetchChanges(in: ckNotification.databaseScope)
    }
    
    // MARK: - IBActions

    @IBAction func muteSoundTapped(_ sender: Any) {
        AppDelegate.userSettings.muteSound.toggle()
    }
    
    @IBAction func hideFeedTapped(_ sender: Any) {
        AppDelegate.userSettings.hideCameraFeed.toggle()
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        AppDelegate.userSettings.pauseDetection.toggle()
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        menuBarMuteItem.state = .off
        menuBarVideoItem.state = .off
        
        menu.addItem(menuBarMuteItem)
        menu.addItem(menuBarVideoItem)
        menu.addItem(menuBarPauseItem)
        
        statusItem.menu = menu
    }
    
    private func listenForUserSettingsUpdates() {
        muteObservation = AppDelegate.userSettings.$muteSound.sink(receiveValue: { muteSound in
            self.menuBarMuteItem.state = muteSound ? .on : .off
            self.dockMuteItem.state = self.menuBarMuteItem.state
            self.mainMenuMuteItem.state = self.menuBarMuteItem.state
        })
        
        videoObservation = AppDelegate.userSettings.$hideCameraFeed.sink(receiveValue: { hideFeed in
            self.menuBarVideoItem.state = hideFeed ? .on : .off
            self.dockVideoItem.state = self.menuBarVideoItem.state
            self.mainMenuVideoItem.state = self.menuBarVideoItem.state
        })
        
        pauseObservation = AppDelegate.userSettings.$pauseDetection.sink(receiveValue: { pauseDetection in
            self.mainMenuPauseItem.state = pauseDetection ? .on : .off
            self.dockPauseItem.state = self.mainMenuPauseItem.state
            self.menuBarPauseItem.state = self.mainMenuPauseItem.state
        })
    }
    
    // Automatically close the app, video isn't working in the background right now. We'll want to fix that.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func setCameraAuthState() {
        switch CameraAuthModel.determineIfAuthorized() {
        case .authorized:
            AppDelegate.userSettings.cameraAuthState = .authorized
            
        case .denied:
            AppDelegate.userSettings.cameraAuthState = .denied
            
        case .notDetermined:
            AppDelegate.userSettings.cameraAuthState = .notDetermined
            
        }
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

