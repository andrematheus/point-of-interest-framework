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
    func testVerifyLocationsJson() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "Locations", ofType: "json")
        let data = FileManager.default.contents(atPath: path!)
        let decoder = JSONDecoder()
        let locationsFile = try! decoder.decode(LocationsFile.self, from: data!)
        XCTAssertEqual(locationsFile.buildings.count, 4)
    }
}
