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
    let b1 = Building(code: "b1", name: "Building 1", numberOfLevels: 7)
    let b2 = Building(code: "b2", name: "Building 2", numberOfLevels: 1)
    let b3 = Building(code: "b3", name: "Building 3", numberOfLevels: 15)

    let locations = [
        Location(buildingCode: "b1", buildingLevel: 2, code: "l1", name: "Location 1", type: .Other),
        Location(buildingCode: "b2", buildingLevel: 1, code: "l2", name: "Location 2", type: .Other),
        Location(buildingCode: "b3", buildingLevel: 6, code: "l3", name: "Location 3", type: .Invisible),
    ]
    
    var buildings: [Building] = []
    var pois: PointsOfInterest!
    
    override func setUp() {
        self.buildings = [b1, b2, b3]
        self.pois = PointsOfInterest(pointsOfInterest: locations, buildings: buildings, routes: [[:]])
    }
    
    func testShouldReturnPointsOfInterestForBuilding() {
        let b1pois = pois.listingForBuildings(buildings: b1)
        XCTAssert(b1pois.count == 1)
        XCTAssertEqual(b1pois[0], locations[0])
    }

    func testShouldSortPointsOfInterestByBuilding() {
        let b1pois = pois.listingForBuildings(buildings: b2, b1)
        XCTAssert(b1pois.count == 2)
        XCTAssertEqual(b1pois[0], locations[1])
        XCTAssertEqual(b1pois[1], locations[0])
    }

    func testShouldNotReturnInvisiblePointsOfInterestInListing() {
        let b1pois = pois.listingForBuildings(buildings: b3)
        XCTAssert(b1pois.count == 0)
    }
}
