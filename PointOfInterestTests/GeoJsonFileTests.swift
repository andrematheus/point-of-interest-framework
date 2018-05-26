//
// Created by André Roque Matheus on 26/05/2018.
// Copyright (c) 2018 André Roque Matheus. All rights reserved.
//

import XCTest
@testable import PointOfInterest

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

class GeoJsonFileTests: XCTestCase {
    func testShouldReadGeoJsonFile() {
        let path = Bundle(for: type(of: self)).path(forResource: "features", ofType: "geojson")
        let data = FileManager.default.contents(atPath: path!)
        let decoder = JSONDecoder()
        let geojson = try! decoder.decode(GeoJsonFile.self, from: data!)
        XCTAssertEqual(geojson.features.count, 16)
        let point = geojson.features[2]
        print(point)
    }
}
