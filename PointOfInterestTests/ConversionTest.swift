//
//  ConversionTest.swift
//  PointOfInterestTests
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import XCTest
@testable import PointOfInterest

class ConversionTests: XCTestCase {
    func testVerifyPlistLoading() {
        let path = Bundle(for: type(of: self)).path(forResource: "Locations", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) as? Dictionary<String, Any> {
            let pointsOfInterest = try! dict.toPointsOfInterest()
            let poi = pointsOfInterest.pointsOfInterest[0]
            let building = pointsOfInterest.buildings[0]
            
            XCTAssertEqual(poi.id.code, "l1")
            XCTAssertEqual(poi.id.buildingCode, "b1")
            XCTAssertEqual(poi.id.buildingLevel, 1)
            XCTAssertEqual(poi.name, "Location 1")
            XCTAssertEqual(poi.type, .ClassRoom)
            
            XCTAssertEqual(building.code, "b1")
            XCTAssertEqual(building.name, "Building 1")
            XCTAssertEqual(building.numberOfLevels, 7)
        }
    }
}
