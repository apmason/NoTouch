/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the sample's app delegate.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
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
        
        return true
    }
}

