//
//  Route.swift
//
//
//  Created by necocen on 2020/12/02.
//

protocol RouteProtocol {
    func configure(_ from: RoutingProtocol)
}

@propertyWrapper public class Route<Routing: ScreenRoutingProtocol>: RouteProtocol {
    public var wrappedValue: Routing { Routing(type: type, ancestors: ancestors) }
    let type: RoutingType
    private var ancestors: [RoutingProtocol] = []
    public init(_ type: RoutingType) {
        self.type = type
    }

    func configure(_ from: RoutingProtocol) {
        ancestors = from.ancestors + [from]
    }
}

public enum RoutingType {
    case push
    case present
    case root
    case embed
    case `switch`
}
