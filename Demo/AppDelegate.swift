//
//  AppDelegate.swift
//  Roota-Demo
//
//  Created by necocen on 2020/12/03.
//

import UIKit
import PromiseKit
import RootaUI

typealias RootTabBarController = TabBarControllerScreen3<ViewControllerA, ViewControllerB, ViewControllerC>

// swiftlint:disable line_length
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PromiseKit.conf.Q = (map: nil, return: nil)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// swiftlint:enable line_length
