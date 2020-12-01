//
//  UITabBarController+Routing.swift
//  
//
//  Created by necocen on 2020/12/02.
//

import UIKit
import PromiseKit
import Roota

public extension SwitchingScreen where Self: UITabBarController {
    func move(to screen: ScreenProtocol) -> Guarantee<Void> {
        guard let vc = screen as? UIViewController else { fatalError() }
        guard let index = viewControllers?.firstIndex(of: vc) else { fatalError() }
        return Guarantee<Void> { seal in
            self.selectedIndex = index
            seal(())
        }
    }

    var currentScreen: ScreenProtocol {
        guard let screen = selectedViewController as? ScreenProtocol else { fatalError() }
        return screen
    }

    func child(for routing: RoutingProtocol) -> ScreenProtocol {
        let vc = viewControllers?.compactMap { $0 as? ScreenProtocol }.first { $0.anyRouting().isEquivalentToOrAncestor(of: routing) }
        return vc!
    }
}
