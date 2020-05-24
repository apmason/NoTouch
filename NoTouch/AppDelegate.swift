/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the sample's app delegate.
*/

import CloudKit
import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
        
        if !FirstRunModel.firstRunCompleted {
            FirstRunModel.setFirstRunCompleted()
            
            initialViewController = storyboard.instantiateViewController(withIdentifier: "TutorialViewController")
            guard let tutorialVC = initialViewController as? TutorialViewController else {
                assertionFailure("Failed to cast as TutorialVC")
                return false
            }
            
            tutorialVC.viewModel = TutorialViewModel()
        }
        else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "VisionViewController")
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        // Used for silent push notifications for CloudKit updates.
        application.registerForRemoteNotifications()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("+++ Application did become active")
        // Determine AVCapture status, block usage if no camera is activated.
        switch CameraAuthModel.determineIfAuthorized() {
        case .authorized:
            CameraAuthModel.removeCameraRequirementOverlay() // Remove just in case things were just updated.
            
        case .denied:
            CameraAuthModel.addCameraRequirementOverlay()
            
        case .notDetermined:
            break // They haven't been asked yet, do nothing.
            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // pass this to common code.
        guard let dict = userInfo as? [String: Any],
            let ckNotification = CKNotification(fromRemoteNotificationDictionary: dict) as? CKDatabaseNotification else {
                return
        }
        
        print("new ck notif")
    }
}

