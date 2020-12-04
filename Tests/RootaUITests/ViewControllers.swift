//
//  ViewControllers.swift
//  Roota-Demo
//
//  Created by necocen on 2020/12/04.
//

import UIKit
import Roota
import RootaUI

typealias ViewController = UIViewController
extension Screen where Self: UIViewController {
    @available(*, unavailable)
    init?(coder: NSCoder) { fatalError() }
}

typealias NavigationController = UINavigationController

func setupWindow(_ root: ViewController) {
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = root
}
