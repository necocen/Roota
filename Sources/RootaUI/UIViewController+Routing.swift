//
//  UIViewController+Routing.swift
//
//
//  Created by necocen on 2020/12/02.
//

#if canImport(UIKit)
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

    @discardableResult func presentScreen(_ screen: ScreenProtocol, animated: Bool) -> Guarantee<Void> {
        if let vc = screen as? UIViewController {
            return Guarantee<Void> { seal in
                self.present(vc, animated: animated) { seal(()) }
            }
        } else {
            fatalError()
        }
    }

    @discardableResult func dismissScreen(animated: Bool) -> Guarantee<Void> {
        Guarantee<Void> { seal in
            self.dismiss(animated: animated) { seal(()) }
        }
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
#endif
