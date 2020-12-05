//
//  UINavigationController+Routing.swift
//
//
//  Created by necocen on 2020/12/02.
//

#if canImport(UIKit)
import UIKit
import PromiseKit
import Roota

public extension SequentialScreen where Self: UINavigationController, RootScreen: UIViewController {
    func push(_ screen: ScreenProtocol) -> Guarantee<Void> {
        if let vc = screen as? UIViewController {
            return guaranteePushViewController(vc, animated: true)
        } else {
            fatalError()
        }
    }

    func pop(to screen: ScreenProtocol) -> Guarantee<Void> {
        if let vc = screen as? UIViewController {
            return guaranteePopToViewController(vc, animated: true)
        } else {
            fatalError()
        }
    }

    func pop() -> Guarantee<Void> {
        return guaranteePopViewController(animated: true)
    }

    var screens: [ScreenProtocol] {
        return viewControllers.compactMap { $0 as? ScreenProtocol }
    }

    init(rootScreen: RootScreen) {
        self.init(rootViewController: rootScreen)
    }
}

extension UINavigationController {
    func guaranteePushViewController(_ viewController: UIViewController, animated: Bool) -> Guarantee<Void> {
        pushViewController(viewController, animated: animated)
        guard let coordinator = transitionCoordinator, animated else {
            // 一度asyncしないとviewControllersが正しい状態にならない
            return Guarantee { seal in DispatchQueue.main.async { seal(()) } }
        }
        return Guarantee<Void> { seal in coordinator.animate(alongsideTransition: nil, completion: { _ in seal(()) }) }
    }

    func guaranteePopViewController(animated: Bool) -> Guarantee<Void> {
        popViewController(animated: animated)
        guard let coordinator = transitionCoordinator, animated else {
            // 一度asyncしないとviewControllersが正しい状態にならない
            return Guarantee { seal in DispatchQueue.main.async { seal(()) } }
        }
        return Guarantee<Void> { seal in
            coordinator.animate(alongsideTransition: nil, completion: { _ in seal(()) })
        }
    }

    func guaranteePopToViewController(_ viewController: UIViewController, animated: Bool) -> Guarantee<Void> {
        popToViewController(viewController, animated: animated)
        guard let coordinator = transitionCoordinator, animated else {
            // 一度asyncしないとviewControllersが正しい状態にならない
            return Guarantee { seal in DispatchQueue.main.async { seal(()) } }
        }
        return Guarantee<Void> { seal in
            coordinator.animate(alongsideTransition: nil, completion: { _ in seal(()) })
        }
    }
}
#endif
