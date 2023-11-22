//
//  AppDelegate.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 24/10/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var secureView: SecureView?

    var screenProtector: ScreenProtector?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        screenProtector = ScreenProtector(window: window)
        screenProtector?.configurePreventionScreenshot()
                
        screenProtector?.screenshotObserver {
            // Handle the screenshot event
            print("Screenshot captured!")
            
            // Temporarily disable the current screen by adding a black overlay
            let overlayView = UIView(frame: UIScreen.main.bounds)
            overlayView.backgroundColor = UIColor.black
            overlayView.alpha = 0.7
            self.window?.addSubview(overlayView)
            
            // Remove the overlay after a short delay (adjust the duration as needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                overlayView.removeFromSuperview()
            }
        }
        
        // Configure an observer for screen recording (available from iOS 11.0 onward)
        if #available(iOS 11.0, *) {
            screenProtector?.screenRecordObserver { isCaptured in
                // Handle the screen recording event
                if isCaptured {
                    print("The screen is currently being recorded.")
                } else {
                    print("Screen recording has been stopped.")
                }
            }
        }
        
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

