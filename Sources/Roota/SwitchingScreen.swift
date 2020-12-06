//
//  SwitchingScreen.swift
//
//
//  Created by necocen on 2020/12/02.
//

import PromiseKit

public protocol SwitchingScreenProtocol: ScreenProtocol {
    @discardableResult func move(to screen: ScreenProtocol) -> Guarantee<Void>
    func child(for routing: RoutingProtocol) -> ScreenProtocol
    var currentScreen: ScreenProtocol { get }
}

public protocol SwitchingScreen: Screen, SwitchingScreenProtocol {}

public extension SwitchingScreen {
    func handleRouting<Routing: ScreenRoutingProtocol>(_ routing: Routing) -> Guarantee<Routing.Screen> {
        Roota.log("Handle \(routing)")
        // 自分自身へのルーティングを受けたときは、何かモーダルが出ていれば閉じ、そうでなければ何もしない
        if self.routing.isEquivalent(to: routing) {
            Roota.log("Route to self")
            if presentedScreen != nil {
                Roota.log("Dismiss presentedScreen \(type(of: presentedScreen!))")
                // swiftlint:disable:next force_cast
                return dismissScreen(animated: true).map { _ in self as! Routing.Screen }
            } else {
                Roota.log("Do nothing")
                // swiftlint:disable:next force_cast
                return .value(self as! Routing.Screen)
            }
        } else if !self.routing.isEquivalentToOrAncestor(of: routing) {
            if self.routing.hasCommonAncestor(with: routing) {
                if let parent = parentScreen {
                    Roota.log("Pass back to parentScreen")
                    return parent.handleRouting(routing)
                }
            }
            fatalError("Can't handle")
        }

        let dismissal: Guarantee<Void>

        // すでにモーダルが出ていて、そのモーダルがrouterを処理できる場合、モーダルに任せる
        if let presentedScreen = presentedScreen,
           presentedScreen.anyRouting().isEquivalentToOrAncestor(of: routing) {
            Roota.log("Forward to presentedScreen \(type(of: presentedScreen))")
            return presentedScreen.handleRouting(routing)
        } else if presentedScreen != nil {
            // モーダルは出ているがrouterを処理できない場合、まず閉じる
            Roota.log("Dismiss presentedScreen \(type(of: presentedScreen!))")
            dismissal = dismissScreen(animated: false)
        } else {
            dismissal = .value
        }

        let child = self.routing.child(toward: routing)
        switch child.type {
        case .present: // 自分が直接presentする場合は出す
            let vc = child.anyInstantiate()
            Roota.log("Present \(type(of: vc))")
            return dismissal.then { _ in self.presentScreen(vc, animated: true) }.then { _ in
                vc.handleRouting(routing)
            }
        case .switch: // タブ切り換え
            if currentScreen.anyRouting().isEquivalentToOrAncestor(of: routing) {
                Roota.log("Forward to current Screen \(type(of: currentScreen))")
                return dismissal.then { _ in self.currentScreen.handleRouting(routing) }
            } else {
                let vc = self.child(for: routing)
                return dismissal.then { _ in self.move(to: vc) }.then { _ in
                    vc.handleRouting(routing)
                }
            }
        default:
            fatalError("Unexpected routing")
        }

    }
}
