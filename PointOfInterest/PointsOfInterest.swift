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
    var visibleInMap: Bool { get }
    var visibleInList: Bool { get }
    var displaysInfo: Bool { get }
    var hasMoreThanOneLevel: Bool { get }
    var levels: [Int] { get }
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
    var planImageKey: String { get }
}

public protocol ShowAsVector: HasQuad {}

public protocol HasPoint {
    var point: CLLocationCoordinate2D { get }
}

// MARK: - Domain Objects
public class Building: Equatable, HasPoint, ShowAsVector, ShowsAsImage, PointOfInterest {
    public var planImageKey: String {
        return self.code
    }
    
    public let code: String
    public let name: String
    public let numberOfLevels: Int
    public let quadPolygon: QuadPolygon
    public let point: CLLocationCoordinate2D
    private var _locationsForList: [Location] = []
    private var locations: [Int: [Location]] = [:]
    
    init(data: BuildingData) {
        self.code = data.code
        self.name = data.name
        self.numberOfLevels = data.numberOfLevels
        let coords = data.outline.geometry.coordinates.coordinates()
        self.quadPolygon = QuadPolygon(topLeft: coords[0], bottomLeft: coords[1], bottomRight: coords[2], topRight: coords[3])
        self.point = data.point.geometry.coordinates.coordinates()[0]
    }
    
    public var visibleInMap: Bool = true
    
    public var visibleInList: Bool {
        return !locations.isEmpty
    }
    
    public var displaysInfo: Bool = false
    
    public var locationsForList: [Location] {
        return self._locationsForList
    }
    
    public var hasMoreThanOneLevel: Bool {
        return locations.keys.count > 1
    }
    
    public var levels: [Int] {
        return Array(locations.keys).sorted()
    }

    
    func addLocation(_ location: Location) {
        locations[location.id.buildingLevel, default: []].append(location)
        if location.visibleInList {
            _locationsForList.append(location)
        }
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

public func floorLabel(_ buildingLevel: Int) -> String {
    if buildingLevel == 0 {
        return "T"
    } else {
        return "\(buildingLevel)º"
    }
}

public struct LocationId: Equatable, Hashable, Codable {
    public let buildingCode: String
    public let buildingLevel: Int
    public let code: String
    
    public var floor: String {
        return floorLabel(buildingLevel)
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

    public var visibleInList: Bool {
        switch self {
        case .Invisible: return false
        case .Access: return false
        default: return true
        }
    }
    
    public var visibleInMap: Bool {
        switch self {
        case .Invisible: return false
        case .Access: return false
        default: return true
        }
    }
}

public class Location: Equatable, Hashable, HasPoint, PointOfInterest {
    public let hasMoreThanOneLevel: Bool = false
    
    public let levels: [Int] = [0]
    
    public let id: LocationId
    public let name: String
    public let type: LocationType
    public let point: CLLocationCoordinate2D
    public let routePoint: CLLocationCoordinate2D
    
    init(data: LocationData) {
        let level = Int(data.buildingLevel)
        self.id = LocationId(buildingCode: data.buildingCode, buildingLevel: level!, code: data.code)
        self.name = data.name
        self.type = LocationType.init(rawValue: data.type)!
        self.point = data.point.geometry.coordinates.coordinates()[0]
        self.routePoint = data.route_point.geometry.coordinates.coordinates()[0]
    }
    
    public var building: Building? = nil
    
    public var visibleInMap: Bool {
        return type.visibleInMap
    }
    
    public var visibleInList: Bool {
        return type.visibleInList
    }

    public var displaysInfo: Bool = true
    
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

public class Fatec: Equatable, ShowAsVector, ShowsAsImage, HasPoint, PointOfInterest {
    public let planImageKey: String = "fatec"
    
    public let hasMoreThanOneLevel: Bool = false
    
    public let levels: [Int] = [0]

    public var title = "FATEC"
    public var description = "Faculdade de Tecnologia de São Paulo"
    public let point: CLLocationCoordinate2D
    public let quadPolygon: QuadPolygon
    
    init(data: FatecData) {
        self.point = data.point.geometry.coordinates.coordinates()[0]
        let coords = data.outline.geometry.coordinates.coordinates()
        self.quadPolygon = QuadPolygon(topLeft: coords[0], bottomLeft: coords[1], bottomRight: coords[2], topRight: coords[3])
    }
    
    public var visibleInMap: Bool = true
    
    public var visibleInList: Bool = false
    
    public var displaysInfo: Bool = false
    
    public static func == (lhs: Fatec, rhs: Fatec) -> Bool {
        return true
    }
}

public class Surroundings: Equatable, HasQuad, PointOfInterest {
    public let hasMoreThanOneLevel: Bool = false
    
    public let levels: [Int] = [0]

    public var title = "Arredores"
    public var description = "Arredores da FATEC"
    public let point: CLLocationCoordinate2D
    public var quadPolygon: QuadPolygon
    
    init(data: SurroundingsData) {
        let coords = data.outline.geometry.coordinates.coordinates()
        self.point = data.point.geometry.coordinates.coordinates()[0]
        self.quadPolygon = QuadPolygon(topLeft: coords[0], bottomLeft: coords[1], bottomRight: coords[2], topRight: coords[3])
    }
    
    public var visibleInMap: Bool = false
    
    public var visibleInList: Bool = false
    
    public var displaysInfo: Bool = false
    
    public static func == (lhs: Surroundings, rhs: Surroundings) -> Bool {
        return true
    }
}

extension Route: PointOfInterest where T: Location {
    public var code: String {
        return "\(from.id.code)-\(to.id.code)"
    }
    
    public var from: Location {
        return self.nodes[0]
    }
    
    public var to: Location {
        return self.nodes.last!
    }
    
    public var coordinates: [CLLocationCoordinate2D] {
        return self.nodes.map { l in l.routePoint }
    }
    
    public var visibleInMap: Bool {
        return true
    }
    
    public var visibleInList: Bool {
        return false
    }
    
    public var displaysInfo: Bool {
        return true
    }
    
    public var hasMoreThanOneLevel: Bool {
        return false
    }
    
    public var levels: [Int] {
        return []
    }
    
    public var title: String {
        let from = self.nodes[0]
        let to = self.nodes.last!
        return "\(from.title) até \(to.title)"
    }
    
    public var description: String {
        let from = self.nodes[0]
        let to = self.nodes.last!
        return "Itinerário de \(from.title) até \(to.title)"
    }
}
