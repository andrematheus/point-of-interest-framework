//
//  PointsOfInterest.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation

struct Building {
    let code: String
    let name: String
    let numberOfLevels: Int
}

struct LocationId: Equatable {
    let buildingCode: String
    let buildingLevel: Int
    let code: String
}

enum LocationType {
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
    let id: LocationId
    let name: String
    let type: LocationType

    init(buildingCode: String, buildingLevel: Int, code: String, name: String, type: LocationType) {
        self.id = LocationId(buildingCode: buildingCode, buildingLevel: buildingLevel, code: code)
        self.name = name
        self.type = type
    }
}

public class PointsOfInterest: NSObject {
    let pointsOfInterest: [Location]
    let pointsOfInterestByBuilding: [String: [Location]]

    public init(pointsOfInterest: [Location]) {
        self.pointsOfInterest = pointsOfInterest
        self.pointsOfInterestByBuilding = pointsOfInterest.reduce(into: [:]) { result, location in
            var l = (result[location.id.buildingCode] ?? [])
            l.append(location)
            result[location.id.buildingCode] = l
        }
    }

    private func iterator() -> LazyCollection<[Location]> {
        return self.pointsOfInterest.lazy
    }

    func listingForBuildings(buildings: Building...) -> [Location] {
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
}
