//
//  SequentialScreen.swift
//  
//
//  Created by necocen on 2020/12/02.
//

import PromiseKit

public protocol SequentialScreenProtocol: ScreenProtocol {
    func push(_ screen: ScreenProtocol) -> Guarantee<Void>
    func pop(to screen: ScreenProtocol) -> Guarantee<Void>
    var screens: [ScreenProtocol] { get }
}

public protocol SequentialScreen: Screen, SequentialScreenProtocol {}

public extension SequentialScreen {
    func handleRouting(_ routing: RoutingProtocol) -> Guarantee<Void> {
        Roota.log("Handle \(routing)")
        // 自分自身へのルーティングを受けたときは、何かモーダルが出ていれば閉じ、そうでなければ何もしない
        if self.routing.isEquivalent(to: routing) {
            Roota.log("Route to self")
            if presentedScreen != nil {
                Roota.log("Dismiss presentedScreen \(type(of: presentedScreen!))")
                return dismissScreen(animated: false)
            } else {
                Roota.log("Do nothing")
                return .value
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

        // 自分が直接presentする場合は出す
        if self.routing.isEquivalentToOrAncestor(of: routing) {
            let child = self.routing.child(toward: routing)
            if child.type == .present {
                let vc = child.anyInstantiate()
                Roota.log("Present \(type(of: vc))")
                return dismissal.then { _ in self.presentScreen(vc, animated: false) }.then { _ in
                    vc.handleRouting(routing)
                }
            }
        }

        // まずいま出ているページが処理できるなら任せればよい
        if let currentScreen = screens.last,
           currentScreen.anyRouting().isEquivalentToOrAncestor(of: routing) {
            Roota.log("Forward to current Screen \(type(of: currentScreen))")
            return dismissal.then { _ in currentScreen.handleRouting(routing) }
        } else if let firstAncestor = screens.reversed().first(where: { $0.anyRouting().isEquivalentToOrAncestor(of: routing) }) {
            Roota.log("Forward to page \(type(of: firstAncestor))")
            return dismissal
                .then { _ in self.pop(to: firstAncestor) }
                .then { _ in firstAncestor.handleRouting(routing) }
        } else {
            fatalError()
        }
    }
}
