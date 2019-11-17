//
//  AppDelegate.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseAuth
import UIKit
import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            XCGLogger.default.outputLevel = .debug
        #else
            XCGLogger.default.outputLevel = .error
        #endif

        ThemeAppier().apply()

        XCGLogger.default.debug("Current user: \(Auth.auth().currentUser?.uid ?? "not login")")

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        Models.shared.notify.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        if AppPreferences.shared.lastLaunchVersion == nil {
            if let video = UIStoryboard(name: "PreviewVideoPlayerViewController", bundle: .main)
                .instantiateViewController(withClass: PreviewVideoPlayerViewController.self) {
                window?.rootViewController?.present(video, animated: true)
            }
        }

        AppPreferences.shared.lastLaunchVersion = UIApplication.shared.version
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
