//
//  File.swift
//
//
//  Created by necocen on 2020/12/02.
//

#if canImport(UIKit)
import UIKit
import Roota

// swiftlint:disable:next line_length
public class TabBarControllerScreen3<First: Screen & UIViewController, Second: Screen & UIViewController, Third: Screen & UIViewController>: UITabBarController, SwitchingScreen where First.Routing: ScreenRouting<First>, Second.Routing: ScreenRouting<Second>, Third.Routing: ScreenRouting<Third> {
    public class Routing: ScreenRouting<TabBarControllerScreen3> {
        @Route(.switch) public var first: First.Routing
        @Route(.switch) public var second: Second.Routing
        @Route(.switch) public var third: Third.Routing

        override public func screen() -> TabBarControllerScreen3<First, Second, Third> {
            let vc = TabBarControllerScreen3(nibName: nil, bundle: nil)
            vc.setViewControllers([first.instantiate(), second.instantiate(), third.instantiate()], animated: false)
            return vc
        }
    }
}

// swiftlint:disable:next line_length
public class TabBarControllerScreen4<First: Screen & UIViewController, Second: Screen & UIViewController, Third: Screen & UIViewController, Fourth: Screen & UIViewController>: UITabBarController, SwitchingScreen where First.Routing: ScreenRouting<First>, Second.Routing: ScreenRouting<Second>, Third.Routing: ScreenRouting<Third>, Fourth.Routing: ScreenRouting<Fourth> {
    public class Routing: ScreenRouting<TabBarControllerScreen4> {
        @Route(.switch) public var first: First.Routing
        @Route(.switch) public var second: Second.Routing
        @Route(.switch) public var third: Third.Routing
        @Route(.switch) public var fourth: Fourth.Routing

        override public func screen() -> TabBarControllerScreen4<First, Second, Third, Fourth> {
            let vc = TabBarControllerScreen4(nibName: nil, bundle: nil)
            vc.setViewControllers([first.instantiate(), second.instantiate(), third.instantiate(), fourth.instantiate()], animated: false)
            return vc
        }
    }
}
#endif
