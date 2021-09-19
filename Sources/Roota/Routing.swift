//
//  Routing.swift
//
//
//  Created by necocen on 2020/12/02.
//

public typealias _Screen = Screen

public protocol RoutingProtocol: AnyObject {
    init()
    init(type: RoutingType, ancestors: [RoutingProtocol])
    var ancestors: [RoutingProtocol] { get }
    var type: RoutingType? { get }
    func anyInstantiate() -> ScreenProtocol
    func isEqual(to another: RoutingProtocol) -> Bool
}

public extension RoutingProtocol {
    func with<T>(_ keyPath: WritableKeyPath<Self, T>, is value: T) -> Self {
        var vself = self
        vself[keyPath: keyPath] = value
        return vself
    }
}

public protocol ScreenRoutingProtocol: RoutingProtocol {
    associatedtype Screen: _Screen
    func screen() -> Screen
}

public extension RoutingProtocol {
    /// ２つのRoutingの先祖の列が同値であるかを判定します。同値性は`isEqual(to:)`で判定します。
    private func hasSameAncestor(to another: RoutingProtocol) -> Bool {
        guard ancestors.count == another.ancestors.count else { return false }
        return zip(ancestors, another.ancestors).allSatisfy { pair in pair.0.isEqual(to: pair.1) }
    }

    /// ２つのRoutingが先祖も含めて同値であることを判定します。
    func isEquivalent(to another: RoutingProtocol) -> Bool {
        return isEqual(to: another) && hasSameAncestor(to: another)
    }

    /// 与えられたRoutingが先祖も含めて同値であるか、自分の子孫であるかを判定します。
    func isEquivalentToOrAncestor(of another: RoutingProtocol) -> Bool {
        if ancestors.count == another.ancestors.count {
            return isEquivalent(to: another)
        } else if ancestors.count < another.ancestors.count {
            return zip(ancestors, another.ancestors).allSatisfy { pair in pair.0.isEqual(to: pair.1) }
                && another.ancestors[ancestors.count].isEqual(to: self)
        } else {
            return false
        }
    }

    func hasCommonAncestor(with another: RoutingProtocol) -> Bool {
        if !ancestors.isEmpty && !another.ancestors.isEmpty {
            return ancestors[0].isEqual(to: another.ancestors[0])
        } else if ancestors.count == another.ancestors.count {
            return isEqual(to: another)
        } else if ancestors.count < another.ancestors.count {
            return isEqual(to: another.ancestors[ancestors.count])
        } else {
            return another.isEqual(to: ancestors[another.ancestors.count])
        }
    }

    func commonAncestor(with another: RoutingProtocol) -> RoutingProtocol? {
        var common: RoutingProtocol?
        for (ancestor, anotherAncestor) in zip(ancestors, another.ancestors) {
            if ancestor.isEqual(to: anotherAncestor) {
                common = ancestor
            } else {
                return common
            }
        }
        if ancestors.count == another.ancestors.count {
            if isEqual(to: another) { return self }
            return common
        } else if ancestors.count < another.ancestors.count {
            if isEqual(to: another.ancestors[ancestors.count]) { return self }
            return common
        } else {
            if another.isEqual(to: ancestors[another.ancestors.count]) { return another }
            return common
        }
    }

    /// 与えられたRoutingに対して一歩接近したRoutingを返します
    /// - Parameter destination: 目標となるRouting。自分の子孫である必要があります。
    func child(toward destination: RoutingProtocol) -> RoutingProtocol {
        // FIXME: 効率が悪い！
        guard isEquivalentToOrAncestor(of: destination) else { fatalError("destination is not descendant of self.") }
        guard !isEquivalent(to: destination) else { fatalError("destination is equivalent to self.") }
        // destinationの先祖を順番に見て、selfの先祖か一致であれば無視、子孫になったらその時点でそれを返す
        for ancestor in destination.ancestors {
            if ancestor.isEquivalentToOrAncestor(of: self) { continue }
            return ancestor
        }
        // destination.ancestorsの中に存在しない場合はdestination自身がそう
        return destination
    }

}

open class ScreenRouting<Screen: _Screen>: ScreenRoutingProtocol {
    open func screen() -> Screen { fatalError("Override me") }
    public let type: RoutingType?
    public private(set) var ancestors: [RoutingProtocol]
    public required init() {
        self.ancestors = []
        self.type = nil
        for case (_, let route as RouteProtocol) in Mirror(reflecting: self).children {
            route.configure(self)
        }
    }

    public required init(type: RoutingType, ancestors: [RoutingProtocol]) {
        self.ancestors = ancestors
        self.type = type
        for case (_, let route as RouteProtocol) in Mirror(reflecting: self).children {
            route.configure(self)
        }
    }

    public final func anyInstantiate() -> ScreenProtocol {
        return instantiate()
    }

    public func instantiate() -> Screen {
        let screen = self.screen()
        screen.routing = self as! Screen.Routing // swiftlint:disable:this force_cast
        return screen
    }

    /// ２つのRoutingの同値性を判定します。先祖は無視します。
    /// デフォルト実装では型が一致すれば同値とみなします。
    open func isEqual(to another: RoutingProtocol) -> Bool {
        return Swift.type(of: self) == Swift.type(of: another)
    }
}
