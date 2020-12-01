//
//  UIViewController+Routing.swift
//  
//
//  Created by necocen on 2020/12/02.
//

import UIKit
import PromiseKit
import Roota

private var routingAssociationKey = "RoutingKey"

public extension Screen where Self: UIViewController {
    var routing: Routing {
        get {
            if let routing = objc_getAssociatedObject(self, &routingAssociationKey) as? Routing {
                return routing
            } else {
                fatalError("UIViewController: routing was not set.")
            }
        } set {
            objc_setAssociatedObject(self,
                                     &routingAssociationKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func presentScreen(_ screen: ScreenProtocol, animated: Bool) -> Guarantee<Void> {
        if let vc = screen as? UIViewController {
            present(vc, animated: animated)
            guard let coordinator = transitionCoordinator, animated else {
                return Guarantee { seal in DispatchQueue.main.async { seal(()) } }
            }
            return Guarantee<Void> { seal in coordinator.animate(alongsideTransition: nil, completion: { _ in seal(()) }) }
        } else {
            fatalError()
        }
    }

    func dismissScreen(animated: Bool) -> Guarantee<Void> {
        dismiss(animated: false)
        guard let coordinator = transitionCoordinator, animated else {
            return Guarantee { seal in DispatchQueue.main.async { seal(()) } }
        }
        return Guarantee<Void> { seal in coordinator.animate(alongsideTransition: nil, completion: { _ in seal(()) }) }
    }

    var presentedScreen: ScreenProtocol? {
        return presentedViewController as? ScreenProtocol
    }

    var navigationScreen: SequentialScreenProtocol? {
        return navigationController as? SequentialScreenProtocol
    }

    var childScreens: [ScreenProtocol] {
        return children.compactMap { $0 as? ScreenProtocol }
    }

    var parentScreen: ScreenProtocol? {
        return parent as? ScreenProtocol ?? presentingViewController as? ScreenProtocol
    }
}
