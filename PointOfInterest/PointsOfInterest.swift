//
//  PointsOfInterest.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation

public protocol Listable {
    var title: String { get }
    var description: String { get }
}

public struct Building: Codable, Equatable {
    public let code: String
    public let name: String
    public let numberOfLevels: Int
    public let outline: Feature
    public let point: Feature
    public var planImage: UIImage? {
        get {
            return UIImage.init(named: self.code)
        }
    }
}

public struct LocationId: Equatable, Hashable, Codable {
    public let buildingCode: String
    public let buildingLevel: Int
    public let code: String
    public var floor: String {
        get {
            if buildingLevel == 0 {
                return "Térreo"
            } else {
                return "\(buildingLevel)º andar"
            }
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

    func showInList() -> Bool {
        switch self {
        case .Invisible: return false
        case .Access: return false
        default: return true
        }
    }
    
    func showInMap() -> Bool {
        switch self {
        case .Invisible: return false
        default: return true
        }
    }
}

public struct Location: Equatable, Hashable, Codable {
    public let id: LocationId
    public let name: String
    public let type: LocationType
    public var point: Feature
    public var building: Building? = nil

    public var hashValue: Int {
        return id.hashValue
    }
}

extension Building: Listable {
    public var title: String {
        return self.name
    }
    
    public var description: String {
        return "\(self.numberOfLevels) andares"
    }
    
    
}

extension Location: Listable {
    public var title: String {
        return self.name
    }
    
    public var description: String {
        return "\(self.building?.name ?? "")\n\(self.id.floor)"
    }
    
    
}

public class PointsOfInterest: NSObject {
    public let pointsOfInterest: [Location]
    public let pointsOfInterestByBuilding: [String: [Location]]
    public let locationsByCode: [String: Location]
    public let routes: Routing<Location>
    public let buildings: [Building]
    public let buildingsByCode: [String: Building]
    public let listables: [Listable]

    public init(pointsOfInterest: [Location], buildings: [Building], routes: [[String:String]]) {
        var pointsOfInterest = pointsOfInterest
    
        self.pointsOfInterestByBuilding = pointsOfInterest.reduce(into: [:]) { result, location in
            var l = (result[location.id.buildingCode] ?? [])
            l.append(location)
            result[location.id.buildingCode] = l
        }
        self.locationsByCode = pointsOfInterest.reduce(into: [:]) { result, location in
            result[location.id.code] = location
        }
        self.buildings = buildings
        self.buildingsByCode = buildings.reduce(into: [:]) { result, building in
            result[building.code] = building
        }
        var wb: [Location]  = []
        for var location in pointsOfInterest {
            location.building = self.buildingsByCode[location.id.buildingCode]
            wb.append(location)
        }
        self.pointsOfInterest = wb
        let builder = Routing<Location>.Builder()
        for location in pointsOfInterest {
            builder.node(t: location)
        }
        for routeSpec in routes {
            if let fromId = routeSpec["from"], let toId = routeSpec["to"],
                let fromLocation = locationsByCode[fromId], let toLocation = locationsByCode[toId] {
                try? builder.route(from: fromLocation, to: toLocation)
                try? builder.route(from: toLocation, to: fromLocation)
            }
        }
        
        var listables: [Listable] = []
        
        for building in self.buildings {
            listables.append(building)
        }
        
        for location in self.pointsOfInterest {
            listables.append(location)
        }
        
        self.listables = listables
        
        self.routes = builder.build()
    }
    
    public func listing() -> [Listable] {
        return listables
    }
    
    public func allBuildings() -> [Building] {
        return buildings
    }

    public func listingForBuildings(buildings: Building...) -> [Location] {
        let filteredLocations: [[Location]] = buildings.map {
            pointsOfInterestByBuilding[$0.code] ?? []
        }
        let flattenedLocations: [Location] = filteredLocations.flatMap {
            $0
        }
        return flattenedLocations.filter {
            $0.type.showInList()
        }
    }
    
    public override var description: String {
        get {
            return "PointsOfInterests(\(self.pointsOfInterest.count) locations, \(self.pointsOfInterestByBuilding.count) buildings)"
        }
    }
}
