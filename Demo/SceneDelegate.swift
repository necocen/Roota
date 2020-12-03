//
//  SceneDelegate.swift
//  Roota-Demo
//
//  Created by necocen on 2020/12/03.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = RootTabBarController.asRootScreen()
        window?.makeKeyAndVisible()
    }
}
