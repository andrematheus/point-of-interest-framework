//
// Created by André Roque Matheus on 14/05/2018.
// Copyright (c) 2018 André Roque Matheus. All rights reserved.
//

import XCTest
@testable import PointOfInterest

class RoutingTest: XCTestCase {
    func testRoutesTrivialPath() {
        let builder = Routing<Int>.Builder()
        builder.node(t: 1)
        builder.node(t: 2)
        builder.node(t: 3)
        try! builder.route(from: 1, to: 2)
        try! builder.route(from: 2, to: 3)
        let routing = builder.build()
        let route = routing.route(from: 1, to: 3)
        XCTAssertNotNil(route)
        XCTAssertEqual(route?.count, 2)
        XCTAssertEqual(route?.legs[0].0, 1)
        XCTAssertEqual(route?.legs[0].1, 2)
        XCTAssertEqual(route?.legs[1].0, 2)
        XCTAssertEqual(route?.legs[1].1, 3)
    }
    
    func testNonExistingPath() {
        let builder = Routing<Int>.Builder()
        builder.node(t: 1)
        builder.node(t: 2)
        builder.node(t: 3)
        try! builder.route(from: 1, to: 2)
        try! builder.route(from: 2, to: 3)
        let routing = builder.build()
        let route = routing.route(from: 3, to: 1)
        XCTAssertNil(route)
    }
}
