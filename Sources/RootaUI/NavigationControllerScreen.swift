//
//  NavigationControllerScreen.swift
//
//
//  Created by necocen on 2020/12/02.
//

#if canImport(UIKit)
import UIKit
import Roota

// swiftlint:disable:next line_length
public class NavigationControllerScreen<Root: Screen & UIViewController>: UINavigationController, SequentialScreen where Root.Routing: ScreenRouting<Root> {
    public class Routing: ScreenRouting<NavigationControllerScreen> {
        @Route(.root) var root: Root.Routing

        override public func screen() -> NavigationControllerScreen<Root> {
            return NavigationControllerScreen(rootViewController: root.instantiate())
        }
    }
}
#endif
