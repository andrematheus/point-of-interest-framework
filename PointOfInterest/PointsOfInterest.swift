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

public struct LocationId: Equatable {
    public let buildingCode: String
    public let buildingLevel: Int
    public let code: String
}

public enum LocationType: String {
    case Invisible
    case ClassRoom
    case Service
    case ThirdPartyService
    case Other

    func isVisible() -> Bool {
        switch self {
        case .Invisible: return false
        default: return true
        }
    }
}

public struct Location: Equatable {
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
}

public class PointsOfInterest: NSObject {
    let pointsOfInterest: [Location]
    let pointsOfInterestByBuilding: [String: [Location]]
    let buildings: [Building]
    let buildingsByCode: [String: Building]

    public init(pointsOfInterest: [Location], buildings: [Building]) {
        self.pointsOfInterest = pointsOfInterest
        self.pointsOfInterestByBuilding = pointsOfInterest.reduce(into: [:]) { result, location in
            var l = (result[location.id.buildingCode] ?? [])
            l.append(location)
            result[location.id.buildingCode] = l
        }
        self.buildings = buildings
        self.buildingsByCode = buildings.reduce(into: [:]) { result, building in
            result[building.code] = building
        }
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
            $0.type.isVisible()
        }
    }
    
    public override var description: String {
        get {
            return "PointsOfInterests(\(self.pointsOfInterest.count) locations, \(self.pointsOfInterestByBuilding.count) buildings)"
        }
    }
}
