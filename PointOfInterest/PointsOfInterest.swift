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

    public init(pointsOfInterest: [Location]) {
        self.pointsOfInterest = pointsOfInterest
    }

    private func iterator() -> LazyCollection<[Location]> {
        return self.pointsOfInterest.lazy
    }

    func forBuildings(buildings: Building...) -> LazyFilterCollection<[Location]> {
        return self.iterator().filter { (poi: Location) in
            buildings.contains(where: { (b: Building) in b.code == poi.id.buildingCode })
        }
    }
}
