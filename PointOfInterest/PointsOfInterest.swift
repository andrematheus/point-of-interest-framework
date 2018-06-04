//
//  PointsOfInterest.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Protocols
 
public protocol PointOfInterest {
    var title: String { get }
    var description: String { get }
}

public struct QuadPolygon: Codable, Equatable {
    let topLeft: CLLocationCoordinate2D
    let bottomLeft: CLLocationCoordinate2D
    let bottomRight: CLLocationCoordinate2D
    let topRight: CLLocationCoordinate2D
    
    static func zeroed() -> QuadPolygon {
        return QuadPolygon(topLeft: CLLocationCoordinate2D.init(),
                           bottomLeft: CLLocationCoordinate2D.init(),
                           bottomRight: CLLocationCoordinate2D.init(),
                           topRight: CLLocationCoordinate2D.init())
    }
    
    public var coordinates: [CLLocationCoordinate2D] {
        return [topLeft, bottomLeft, bottomRight, topRight]
    }
}

public protocol HasQuad {
    var quadPolygon: QuadPolygon { get }
}

public protocol ShowsAsImage: HasQuad {
    var planImage: UIImage? { get }
}

public protocol ShowAsVector: HasQuad {}

public protocol HasPoint {
    var point: CLLocationCoordinate2D { get }
}

// MARK: - Domain Objects
public class Building: Equatable, HasPoint, ShowAsVector, ShowsAsImage, PointOfInterest {
    public let code: String
    public let name: String
    public let numberOfLevels: Int
    public let quadPolygon: QuadPolygon
    public let point: CLLocationCoordinate2D
    
    init(data: BuildingData) {
        self.code = data.code
        self.name = data.name
        self.numberOfLevels = data.numberOfLevels
        let coords = data.outline.geometry.coordinates.coordinates()
        self.quadPolygon = QuadPolygon(topLeft: coords[0], bottomLeft: coords[1], bottomRight: coords[2], topRight: coords[3])
        self.point = data.point.geometry.coordinates.coordinates()[0]
    }
    
    // MARK: ShowAsImage
    public var planImage: UIImage? {
        return UIImage.init(named: self.code)
    }
    
    // MARK: Equatable
    public static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.code == rhs.code
    }
    
    // MARK: Listable
    public var title: String {
        return self.name
    }
    
    public var description: String {
        return "\(self.numberOfLevels) andares"
    }
}

public struct LocationId: Equatable, Hashable, Codable {
    public let buildingCode: String
    public let buildingLevel: Int
    public let code: String
    
    public var floor: String {
        if buildingLevel == 0 {
            return "Térreo"
        } else {
            return "\(buildingLevel)º andar"
        }
    }
    
    public var hashValue: Int {
        return buildingCode.hashValue ^ buildingLevel.hashValue ^ code.hashValue
    }
}

public enum LocationType: String, Codable, Equatable {
    case Invisible
    case ClassRoom
    case Service
    case ThirdPartyService
    case Access
    case Other

    public func showInList() -> Bool {
        switch self {
        case .Invisible: return false
        case .Access: return false
        default: return true
        }
    }
    
    public func showInMap() -> Bool {
        switch self {
        case .Invisible: return false
        default: return true
        }
    }
}

public class Location: Equatable, Hashable, HasPoint, PointOfInterest {
    public let id: LocationId
    public let name: String
    public let type: LocationType
    public let point: CLLocationCoordinate2D
    
    init(data: LocationData) {
        let level = Int(data.buildingLevel)
        self.id = LocationId(buildingCode: data.buildingCode, buildingLevel: level!, code: data.code)
        self.name = data.name
        self.type = LocationType.init(rawValue: data.type)!
        self.point = data.point.geometry.coordinates.coordinates()[0]
    }
    
    public var building: Building? = nil

    // MARK: Hashable
    public var hashValue: Int {
        return id.hashValue
    }
    
    // MARK: Equatable
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Listable
    public var title: String {
        return self.name
    }
    
    public var description: String {
        return "\(self.id.floor)"
    }
}

public class Fatec: ShowAsVector, ShowsAsImage, HasPoint {
    public let point: CLLocationCoordinate2D
    public let quadPolygon: QuadPolygon
    
    init(data: FatecData) {
        self.point = data.point.geometry.coordinates.coordinates()[0]
        let coords = data.outline.geometry.coordinates.coordinates()
        self.quadPolygon = QuadPolygon(topLeft: coords[0], bottomLeft: coords[1], bottomRight: coords[2], topRight: coords[3])
    }
    
    public var planImage: UIImage? {
        return UIImage.init(named: "fatec")
    }
}
