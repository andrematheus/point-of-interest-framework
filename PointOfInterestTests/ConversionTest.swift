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
            print(pointsOfInterest)
            let poi = pointsOfInterest.pointsOfInterest[0]
            print(poi)
        }
    }
}
