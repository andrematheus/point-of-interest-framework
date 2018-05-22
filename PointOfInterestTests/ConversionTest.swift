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
            let routes = pointsOfInterest.routes
            
            XCTAssertEqual(poi.id.code, "sa0s1")
            XCTAssertEqual(poi.id.buildingCode, "sa")
            XCTAssertEqual(poi.id.buildingLevel, 0)
            XCTAssertEqual(poi.name, "Biblioteca")
            XCTAssertEqual(poi.type, .Service)
            
            XCTAssertEqual(building.code, "sa")
            XCTAssertEqual(building.name, "Santiago")
            XCTAssertEqual(building.numberOfLevels, 5)
            
            XCTAssertNotNil(routes.routes[poi])
            
            let route = routes.route(from: pointsOfInterest.pointsOfInterest[0], to: pointsOfInterest.pointsOfInterest[1])
            XCTAssertNotNil(route)
            for leg in (route?.legs)! {
                print("Leg: \(leg)")
            }
        }
    }
}
