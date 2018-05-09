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

extension Dictionary : PointsOfInterestConvertible where Key == String, Value : Any {
    public func toPointsOfInterest() throws -> PointsOfInterest {
        let locationsDict = self["locations"] as? [Dictionary<Key,Value>]
        if let locations = locationsDict?.map({ try! locationFromDict(dict: $0) }) {
            return PointsOfInterest(pointsOfInterest: locations)
        } else {
            throw PointsOfInterestConversionError.InvalidInput
        }
    }
    
    private func locationFromDict(dict: Dictionary<Key, Value>) throws -> Location {
        if let idDict = dict["id"] as? Dictionary<Key, Value>,
            let name = dict["name"] as? String,
            let typeName = dict["type"] as? String {
            
            let type = LocationType(rawValue: typeName)!
            let id = try! locationIdFromDict(dict: idDict)
            return Location(id: id, name: name, type: type)
        } else {
            throw PointsOfInterestConversionError.InvalidInput
        }
    }
    
    private func locationIdFromDict(dict: Dictionary<Key, Value>) throws -> LocationId {
        if let buildingCode = dict["buildingCode"] as? String,
            let buildingLevel = dict["buildingLevel"] as? Int,
            let code = dict["code"] as? String {
            return LocationId(buildingCode: buildingCode, buildingLevel: buildingLevel, code: code)
        } else {
            throw PointsOfInterestConversionError.InvalidInput
        }
    }
}
