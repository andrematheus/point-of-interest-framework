//
// Created by André Roque Matheus on 14/05/2018.
// Copyright (c) 2018 André Roque Matheus. All rights reserved.
//

import Foundation

public struct Route<T> {
    public let nodes: [T]
    public let legs: [(T,T)]
    
    init(nodes: [T]) {
        self.nodes = nodes
        self.legs = Array(zip(
            nodes.dropLast(),
            nodes.dropFirst()
        ))
    }

    public var count: Int {
        get {
            return legs.count
        }
    }
}

public class Routing<T: Hashable>: NSObject {
    let nodes: Set<T>
    let routes: [T: [T]]
    
    init(nodes: Set<T>, routes: [T: [T]]) {
        self.nodes = nodes
        self.routes = routes
    }
    
    public func route(from: T, to: T) -> Route<T>? {
        var nodeStack: [(T, [T])] = []
        nodeStack.append((from, [from]))
        var used: Set<T> = []
        
        while nodeStack.count > 0 {
            let node = nodeStack.removeFirst()
            if let nextHops = routes[node.0] {
                for hop in nextHops {
                    if hop == to {
                        let routeHops = node.1 + [hop]
                        return Route(nodes: routeHops)
                    } else if !used.contains(hop) {
                        used.insert(hop)
                        nodeStack.append((hop, node.1 + [hop]))
                    }
                }
            }
        }
        
        return nil
    }
    
    class Builder {
        enum BuildingError: Error {
            case RouteStartingPointNotPresent
            case RouteEndingPointNotPresent
        }
        
        var nodes: Set<T> = []
        var routes: [T: [T]] = [:]

        func node(t: T) {
            if !nodes.contains(t) {
                nodes.insert(t)
                routes[t] = []
            }
        }

        func route(from: T, to: T) throws {
            guard nodes.contains(from) else {
                throw BuildingError.RouteStartingPointNotPresent
            }
            guard nodes.contains(to) else {
                throw BuildingError.RouteEndingPointNotPresent
            }
            routes[from]!.append(to)
        }
        
        func build() -> Routing<T> {
            return Routing(nodes: nodes, routes: routes)
        }
    }
}

extension Routing where T: Location {
    public func debugRoute(selection: PointOfInterest, selectedLevel: Int) -> Routes {
        var dbg = [Route<Location>]()
        let building: Building?
        if let location = selection as? Location {
            building = location.building
        } else if let b = selection as? Building {
            building = b
        } else {
            building = nil
        }
        for (k,vs) in self.routes {
            for v in vs {
                if let b = building {
                    if (k.building == b && k.id.buildingLevel == selectedLevel) || (v.building == b && v.id.buildingLevel == selectedLevel) {
                        dbg.append(Route(nodes: [k, v]))
                    }
                } else {
                    if k.id.buildingLevel == selectedLevel || v.id.buildingLevel == selectedLevel {
                        dbg.append(Route(nodes: [k, v]))
                    }
                }
            }
        }
        
        let routes = Routes()
        routes.routes = dbg
        return routes
    }
}
