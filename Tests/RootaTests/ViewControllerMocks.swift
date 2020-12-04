//
//  ViewControllerMocks.swift
//
//
//  Created by necocen on 2020/12/02.
//

import Foundation
import PromiseKit
import Roota

/// Simulated animation duration
private let animationDuration: TimeInterval = 0.2

class ViewController {
    fileprivate(set) var presentedViewController: ViewController?
    fileprivate(set) weak var presentingViewController: ViewController?
    fileprivate(set) weak var navigationController: NavigationController?
    fileprivate(set) var children: [ViewController] = []
    var _routing: RoutingProtocol!

    func present(_ viewController: ViewController, animated: Bool) -> Guarantee<Void> {
        guard presentedViewController == nil else { fatalError("Already presenting") }
        return after(seconds: animated ? animationDuration : 0).done { _ in
            self.presentedViewController = viewController
            viewController.presentingViewController = self
        }
    }

    func dismiss(animated: Bool) -> Guarantee<Void> {
        guard let presentedViewController = presentedViewController else { fatalError("Presenting nothing") }
        return after(seconds: animated ? animationDuration : 0).done { _ in
            self.presentedViewController = nil
            presentedViewController.presentingViewController = nil
        }
    }

    init() {}
    init(nibName: String?, bundle: Bundle?) {}
}

class NavigationController: ViewController {
    fileprivate(set) var viewControllers: [ViewController] = []
    init(rootViewController: ViewController) {
        super.init()
        rootViewController.navigationController = self
        self.viewControllers = [rootViewController]
        children = [rootViewController]
    }
}

extension Screen where Self: ViewController {
    var routing: Routing {
        get {
            return _routing as! Routing
        } set {
            _routing = newValue
        }
    }

    var presentedScreen: ScreenProtocol? {
        return presentedViewController as? ScreenProtocol
    }

    func presentScreen(_ screen: ScreenProtocol, animated: Bool) -> Guarantee<Void> {
        guard let viewController = screen as? ViewController else { fatalError("Not ViewController") }
        if let navigationController = navigationController {
            return navigationController.present(viewController, animated: animated)
        }
        return present(viewController, animated: animated)
    }

    func dismissScreen(animated: Bool) -> Guarantee<Void> {
        return dismiss(animated: animated)
    }

    var navigationScreen: SequentialScreenProtocol? {
        return navigationController as? SequentialScreenProtocol
    }

    var parentScreen: ScreenProtocol? {
        return navigationController as? ScreenProtocol ?? presentingViewController as? ScreenProtocol
    }

    var childScreens: [ScreenProtocol] {
        return children.compactMap { $0 as? ScreenProtocol }
    }

}

extension SequentialScreen where Self: NavigationController {
    var screens: [ScreenProtocol] {
        return viewControllers.compactMap { $0 as? ScreenProtocol }
    }

    func push(_ screen: ScreenProtocol) -> Guarantee<Void> {
        guard let viewController = screen as? ViewController else { fatalError("Not ViewController") }
        guard viewController.navigationController == nil else { fatalError("Inconsistent push") }
        return after(seconds: animationDuration).done { _ in
            viewController.navigationController = self
            self.viewControllers.append(viewController)
            self.children.append(viewController)
        }
    }

    func pop() -> Guarantee<Void> {
        guard screens.count > 1 else { fatalError("Can't pop") }
        return pop(to: screens[screens.count - 2])
    }

    func pop(to screen: ScreenProtocol) -> Guarantee<Void> {
        guard let viewController = screen as? ViewController else { fatalError("Not ViewController") }
        return after(seconds: animationDuration).done { _ in
            for vc in self.viewControllers.reversed() {
                if vc === viewController { break }
                guard vc.navigationController === self else { fatalError("Inconsistent pop") }
                vc.navigationController = nil
                self.viewControllers.removeAll { $0 === vc }
                self.children.removeAll { $0 === vc }
            }
            if self.viewControllers.isEmpty { fatalError("Inconsistent pop") }
        }
    }
}

func setupWindow(_ root: ViewController) {
    // Do Nothing
}
