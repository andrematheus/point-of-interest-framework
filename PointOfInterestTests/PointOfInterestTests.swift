//
//  PointOfInterestTests.swift
//  PointOfInterestTests
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import XCTest
@testable import PointOfInterest

class PointOfInterestTests: XCTestCase {
    func testShouldReturnPointsOfInterestForBuilding() {
        let locations = [
            Location(buildingCode: "b1", buildingLevel: 1, code: "l1", name: "Location 1"),
            Location(buildingCode: "b2", buildingLevel: 1, code: "l2", name: "Location 2"),
        ]
        let b1 = Building(code: "b1", name: "Building 1", numberOfLevels: 7)
        let pois = PointsOfInterest(pointsOfInterest: locations)
        let b1pois = pois.forBuildings(buildings: b1)
        XCTAssert(b1pois.count == 1)
        XCTAssertEqual(b1pois[0], locations[0])
    }
}
