//
//  AppDelegate.swift
//  NoTouch-iOS
//
//  Created by Alexander Mason on 5/24/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import NoTouchCommon
import CloudKit
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
    
    public func fetchLatestRecords(completion: @escaping (Result<Void, Error>) -> Void) {
        self.alertViewModel.fetchLatestRecords { result in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
    }
    
    static let shared = DataModel()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Register for push notifications
        application.registerForRemoteNotifications()
        
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

// MARK: - Push Notifications

extension AppDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard CKNotification(fromRemoteNotificationDictionary: userInfo) != nil else {
            completionHandler(.noData)
            return
        }
        
        // Give a slight delay and run on a background queue, we want to make sure the data can be fetched from the DB.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DataModel.shared.fetchLatestRecords { result in
                switch result {
                case .success:
                    completionHandler(.newData)
                    
                case .failure:
                    completionHandler(.failed)
                    
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
}

