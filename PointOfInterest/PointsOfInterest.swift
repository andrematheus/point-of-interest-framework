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

struct LocationId : Equatable {
    let buildingCode: String
    let buildingLevel: Int
    let code: String
}

public struct Location : Equatable {
    let id: LocationId
    let name: String

    init(buildingCode: String, buildingLevel: Int, code: String, name: String) {
        self.id = LocationId(buildingCode: buildingCode, buildingLevel: buildingLevel, code: code)
        self.name = name
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

    func forBuildings(buildings: Building...) -> [Location] {
        return buildings.map { pointsOfInterestByBuilding[$0.code] }.flatMap { $0 ?? [] }
    }
}
