//
//  PointsOfInterestIO.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation

public protocol PointsOfInterestConvertible {
    func toPointsOfInterest() throws -> PointsOfInterest
}

public enum PointsOfInterestConversionError : Error {
    case InvalidInput
    case InvalidLocationType
}

public struct LocationsFile: Codable {
    let buildings: [Building]
    let locations: [Location]
    let routes: [[String:String]]
}

extension Data : PointsOfInterestConvertible {
    public func toPointsOfInterest() throws -> PointsOfInterest {
        let decoder = JSONDecoder()
        let locationsFile = try! decoder.decode(LocationsFile.self, from: self)
        return PointsOfInterest(pointsOfInterest: locationsFile.locations, buildings: locationsFile.buildings, routes: locationsFile.routes)
    }
}
