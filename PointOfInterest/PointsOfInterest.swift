//
//  PointsOfInterest.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation

public struct Building {
    public let code: String
    public let name: String
    public let numberOfLevels: Int
}

public struct LocationId: Equatable, Hashable {
    public let buildingCode: String
    public let buildingLevel: Int
    public let code: String
    public var floor: String {
        get {
            if buildingLevel == 0 {
                return "Térreo"
            } else {
                return "\(buildingLevel)º andar"
            }
        }
    }
    
    public var hashValue: Int {
        return buildingCode.hashValue ^ buildingLevel.hashValue ^ code.hashValue
    }
}

public enum LocationType: String {
    case Invisible
    case ClassRoom
    case Service
    case ThirdPartyService
    case Access
    case Other

    func showInList() -> Bool {
        switch self {
        case .Invisible: return false
        case .Access: return false
        default: return true
        }
    }
    
    func showInMap() -> Bool {
        switch self {
        case .Invisible: return false
        default: return true
        }
    }
}

public struct Location: Equatable, Hashable {
    public let id: LocationId
    public let name: String
    public let type: LocationType

    init(id: LocationId, name: String, type: LocationType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    init(buildingCode: String, buildingLevel: Int, code: String, name: String, type: LocationType) {
        self.id = LocationId(buildingCode: buildingCode, buildingLevel: buildingLevel, code: code)
        self.name = name
        self.type = type
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
}

public class PointsOfInterest: NSObject {
    let pointsOfInterest: [Location]
    let pointsOfInterestByBuilding: [String: [Location]]
    let locationsByCode: [String: Location]
    let routes: Routing<Location>
    let buildings: [Building]
    let buildingsByCode: [String: Building]

    public init(pointsOfInterest: [Location], buildings: [Building], routes: [[String:String]]) {
        self.pointsOfInterest = pointsOfInterest
        self.pointsOfInterestByBuilding = pointsOfInterest.reduce(into: [:]) { result, location in
            var l = (result[location.id.buildingCode] ?? [])
            l.append(location)
            result[location.id.buildingCode] = l
        }
        self.locationsByCode = pointsOfInterest.reduce(into: [:]) { result, location in
            result[location.id.code] = location
        }
        self.buildings = buildings
        self.buildingsByCode = buildings.reduce(into: [:]) { result, building in
            result[building.code] = building
        }
        let builder = Routing<Location>.Builder()
        for location in pointsOfInterest {
            builder.node(t: location)
        }
        for routeSpec in routes {
            if let fromId = routeSpec["from"], let toId = routeSpec["to"],
                let fromLocation = locationsByCode[fromId], let toLocation = locationsByCode[toId] {
                try? builder.route(from: fromLocation, to: toLocation)
                try? builder.route(from: toLocation, to: fromLocation)
            }
        }
        self.routes = builder.build()
    }
    
    public func listing() -> [Location] {
        return pointsOfInterest
    }
    
    public func allBuildings() -> [Building] {
        return buildings
    }

    public func listingForBuildings(buildings: Building...) -> [Location] {
        let filteredLocations: [[Location]] = buildings.map {
            pointsOfInterestByBuilding[$0.code] ?? []
        }
        let flattenedLocations: [Location] = filteredLocations.flatMap {
            $0
        }
        return flattenedLocations.filter {
            $0.type.showInList()
        }
    }
    
    public override var description: String {
        get {
            return "PointsOfInterests(\(self.pointsOfInterest.count) locations, \(self.pointsOfInterestByBuilding.count) buildings)"
        }
    }
}
