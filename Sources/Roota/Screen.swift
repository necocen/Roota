//
//  Screen.swift
//
//
//  Created by necocen on 2020/12/02.
//

import PromiseKit

public protocol ScreenProtocol: class {
    func handleRouting<Routing: ScreenRoutingProtocol>(_ routing: Routing) -> Guarantee<Routing.Screen>
    func routeBack() -> Guarantee<ScreenProtocol>
    func anyRouting() -> RoutingProtocol
    func presentScreen(_ screen: ScreenProtocol, animated: Bool) -> Guarantee<Void>
    func dismissScreen(animated: Bool) -> Guarantee<Void>
    var presentedScreen: ScreenProtocol? { get }
    var navigationScreen: SequentialScreenProtocol? { get }
    var childScreens: [ScreenProtocol] { get }
    var parentScreen: ScreenProtocol? { get }
}

public protocol Screen: ScreenProtocol {
    associatedtype Routing: ScreenRoutingProtocol
    var routing: Routing { get set }
}

public extension Screen {
    func anyRouting() -> RoutingProtocol {
        return routing
    }

    func ancestor<Parent: Screen, Routing: ScreenRoutingProtocol>(_ parent: Parent.Type, _ keyPath: KeyPath<Parent.Routing, Routing>) -> Routing {
        guard let ancestor = routing.ancestors.compactMap({ $0 as? Parent.Routing }).last else {
            fatalError("親が存在しない")
        }
        return ancestor[keyPath: keyPath]
    }

    func descendant<Routing: ScreenRoutingProtocol>(_ keyPath: KeyPath<Self.Routing, Routing>) -> Routing {
        return routing[keyPath: keyPath]
    }

    @discardableResult func route<Routing: ScreenRoutingProtocol>(to routing: Routing) -> Guarantee<Routing.Screen> {
        return handleRouting(routing)
    }

    @discardableResult func route<Routing: ScreenRoutingProtocol>(to keyPath: KeyPath<Self.Routing, Routing>) -> Guarantee<Routing.Screen> {
        return handleRouting(routing[keyPath: keyPath])
    }

    @discardableResult func route<Routing: ScreenRoutingProtocol, T>(to keyPath: KeyPath<Self.Routing, Routing>,
                                                                     with keyPath1: WritableKeyPath<Routing, T>,
                                                                     _ value1: T) -> Guarantee<Routing.Screen> {
        var child = routing[keyPath: keyPath]
        child[keyPath: keyPath1] = value1
        return handleRouting(child)
    }

    @discardableResult func route<Routing: ScreenRoutingProtocol, T, U>(to keyPath: KeyPath<Self.Routing, Routing>,
                                                                        with keyPath1: WritableKeyPath<Routing, T>,
                                                                        _ value1: T,
                                                                        _ keyPath2: WritableKeyPath<Routing, U>,
                                                                        _ value2: U) -> Guarantee<Routing.Screen> {
        var child = routing[keyPath: keyPath]
        child[keyPath: keyPath1] = value1
        child[keyPath: keyPath2] = value2
        return handleRouting(child)
    }

    // swiftlint:disable:next function_parameter_count
    @discardableResult func route<Routing: ScreenRoutingProtocol, T, U, V>(to keyPath: KeyPath<Self.Routing, Routing>,
                                                                           with keyPath1: WritableKeyPath<Routing, T>,
                                                                           _ value1: T, _ keyPath2: WritableKeyPath<Routing, U>,
                                                                           _ value2: U, _ keyPath3: WritableKeyPath<Routing, V>,
                                                                           _ value3: V) -> Guarantee<Routing.Screen> {
        var child = routing[keyPath: keyPath]
        child[keyPath: keyPath1] = value1
        child[keyPath: keyPath2] = value2
        child[keyPath: keyPath3] = value3
        return handleRouting(child)
    }

    @discardableResult func route<From: Screen,
        Routing: ScreenRoutingProtocol>(from: From.Type,
                                        to keyPath: KeyPath<From.Routing, Routing>) -> Guarantee<Routing.Screen> {
        return handleRouting(ancestor(from, keyPath))
    }

    @discardableResult func route<From: Screen, Routing: ScreenRoutingProtocol, T>(from: From.Type,
                                                                                   to keyPath: KeyPath<From.Routing, Routing>,
                                                                                   with keyPath1: WritableKeyPath<Routing, T>,
                                                                                   _ value1: T) -> Guarantee<Routing.Screen> {
        var ancestor = self.ancestor(from, keyPath)
        ancestor[keyPath: keyPath1] = value1
        return handleRouting(ancestor)
    }

    static func asRootScreen() -> Self {
        let routing = Routing()
        let screen = routing.anyInstantiate() as! Self // swiftlint:disable:this force_cast
        screen.routing = routing
        return screen
    }

    @discardableResult func routeBack() -> Guarantee<ScreenProtocol> {
        switch routing.type {
        case .present:
            guard let parentScreen = parentScreen else { fatalError("Inconsistent routing") }
            return parentScreen.dismissScreen(animated: true).map { _ in parentScreen }
        case .push:
            guard let navigationScreen = navigationScreen else { fatalError("Inconsistent routing") }
            return navigationScreen.pop().map { _ in navigationScreen.screens.last! }
        case .root:
            guard let navigationScreen = navigationScreen else { fatalError("Inconsistent routing") }
            return navigationScreen.routeBack()
        case .switch, .embed:
            guard let parentScreen = parentScreen else { fatalError("Inconsistent routing") }
            return parentScreen.routeBack()
        case nil:
            fatalError("Can't route back from Root screen.")
        }
    }

    // swiftlint:disable:next function_body_length
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
        case .push:
            guard let navigationScreen = navigationScreen else {
                preconditionFailure("Inconsistent routing: \(self) must have navigationScreen.")
            }
            // すでに出ている画面にハンドル可能な場合はそこにforwardする
            if let handlingScreen = navigationScreen.screens.reversed().first(where: { routing.isEquivalentToOrAncestor(of: $0.anyRouting()) }) {
                return dismissal.then { _ in handlingScreen.handleRouting(routing) }
            } else { // そうでなければ１つpushする
                let screen = child.anyInstantiate()
                Roota.log("Push \(type(of: screen))")
                return dismissal.then { _ in navigationScreen.push(screen) }.then { _ in
                    return screen.handleRouting(routing)
                }
            }
        case .present:
            let screen = child.anyInstantiate()
            Roota.log("Present \(type(of: screen))")
            return dismissal.then { _ in self.presentScreen(screen, animated: false) }.then { _ in
                return screen.handleRouting(routing)
            }
        case .embed:
            if let embedded = childScreens.first(where: { $0.anyRouting().isEquivalentToOrAncestor(of: child) }) {
                return dismissal.then { _ in embedded.handleRouting(routing) }
            } else {
                fatalError("Any children can not handle given routing")
            }
        case .root, .switch, nil:
            fatalError("Unexpected routing")
        }
    }
}
