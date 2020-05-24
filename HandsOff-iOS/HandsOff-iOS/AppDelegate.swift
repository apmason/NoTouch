//
//  AppDelegate.swift
//  HandsOff-iOS
//
//  Created by Alexander Mason on 5/24/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import NoTouchCommon
import UIKit

class DataModel {
    
    private let alertViewModel: AlertViewModel

    public let userSettings: UserSettings = UserSettings()
    
    public let contentViewModel: ContentViewModel
    
    private init() {
        self.alertViewModel = AlertViewModel(userSettings: userSettings,
                                              database: CloudKitDatabase())
        
        self.contentViewModel = ContentViewModel(alertModel: alertViewModel, userSettings: userSettings)
    }
    
    static let shared = DataModel()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

