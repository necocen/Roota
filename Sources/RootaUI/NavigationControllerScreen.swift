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
public class NavigationControllerScreen<RootScreen: Screen & UIViewController>: UINavigationController, SequentialScreen where RootScreen.Routing: ScreenRouting<RootScreen> {

    public class Routing: ScreenRouting<NavigationControllerScreen> {
        @Route(.root) var root: RootScreen.Routing

        override public func screen() -> NavigationControllerScreen<RootScreen> {
            return NavigationControllerScreen(rootScreen: root.instantiate())
        }
    }
}
#endif
