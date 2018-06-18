//
//  PointsOfInterestIO.swift
//  PointOfInterest
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init()
        longitude = try container.decode(Double.self)
        latitude = try container.decode(Double.self)
    }
}

struct BuildingData: Decodable {
    let code: String
    let name: String
    let numberOfLevels: Int
    let outline: Feature
    let point: Feature
}

struct LocationData: Decodable {
    let buildingCode: String
    let buildingLevel: String
    let code: String
    let name: String
    let type: String
    let point: Feature
    let route_point: Feature
    
    private enum CodingKeys: String, CodingKey {
        case buildingCode = "id.buildingCode"
        case buildingLevel = "id.buildingLevel"
        case code = "id.code"
        case name
        case point
        case route_point
        case type
    }
}

struct FatecData: Decodable {
    let point: Feature
    let outline: Feature
}

struct SurroundingsData: Decodable {
    let point: Feature
    let outline: Feature
}

struct MapDataFile: Decodable {
    let buildingData: [BuildingData]
    let locationData: [LocationData]
    let routeData: [[String : String]]
    let fatecData: FatecData
    let surroundingsData: SurroundingsData
    
    private enum CodingKeys: String, CodingKey {
        case buildingData = "buildings"
        case locationData = "locations"
        case routeData = "routes"
        case fatecData = "fatec"
        case surroundingsData = "surroundings"
    }
}

func indexedLocations(locations: [Location]) -> [String: Location] {
    return locations.reduce(into: [:]) { result, location in
        result[location.id.code] = location
    }
}

func indexedBuildings(buildings: [Building]) -> [String: Building]{
    return buildings.reduce(into: [:]) { result, building in
        result[building.code] = building
    }
}

func locationsIndexedByBuilding(locations: [Location]) -> [String: [Location]] {
    return locations.reduce(into: [:]) { result, location in
        result[location.id.buildingCode, default: []].append(location)
    }
}

func allPointsOfInterest(buildings: [Building], locations: [Location]) -> [PointOfInterest] {
    var pois: [PointOfInterest] = []
    pois.append(contentsOf: buildings)
    pois.append(contentsOf: locations)
    return pois
}

func poisVisibleInMap(pois: [PointOfInterest]) {
    
}

func poisVisibleInListing(pois: [PointOfInterest]) {
    
}

func setupRoutes(locations: [Location], locationsByCode: [String: Location], routeData: [[String: String]]) -> Routing<Location> {
    let builder = Routing<Location>.Builder()
    for location in locations {
        builder.node(t: location)
    }
    for routeSpec in routeData {
        if let fromId = routeSpec["from"], let toId = routeSpec["to"],
            let fromLocation = locationsByCode[fromId], let toLocation = locationsByCode[toId] {
            try? builder.route(from: fromLocation, to: toLocation)
            try? builder.route(from: toLocation, to: fromLocation)
        } else {
            print("ERRO: \(routeSpec)")
        }
    }
    
    return builder.build()
}

func updateBuildingInLocations(_ locations: [Location], buildingsByCode: [String: Building]) {
    for location in locations {
        location.building = buildingsByCode[location.id.buildingCode]
        location.building?.addLocation(location)
    }
}

public class MapData {
    public let fatec: Fatec
    public let surroundings: Surroundings
    public let routes: Routing<Location>
    public let locationsByCode: [String : Location]
    public let buildingsByCode: [String : Building]
    public let locationsByBuilding: [String: [Location]]
    public let pointsOfInterestForMap: [PointOfInterest]
    public let pointsOfInterestForList: [PointOfInterest]
    public let buildingsForList: [Building]
    public let locationsForList: [Location]
    public let locationsForMap: [Location]
    public let locationsWithoutBuilding: [Location]
    public let buildings: [Building]
    public let locations: [Location]
    
    let pointsOfInterest: [PointOfInterest]
    
    // MARK: - Init
    init(with dataFile: MapDataFile) {
        self.buildings = dataFile.buildingData.map(Building.init)
        self.locations = dataFile.locationData.map(Location.init)
        self.fatec = Fatec(data: dataFile.fatecData)
        self.surroundings = Surroundings(data: dataFile.surroundingsData)
        self.locationsByCode = indexedLocations(locations: self.locations)
        self.buildingsByCode = indexedBuildings(buildings: self.buildings)
        self.routes = setupRoutes(locations: locations, locationsByCode: self.locationsByCode, routeData: dataFile.routeData)
        self.pointsOfInterest = allPointsOfInterest(buildings: self.buildings, locations: self.locations)
        self.locationsByBuilding = locationsIndexedByBuilding(locations: self.locations)
        updateBuildingInLocations(self.locations, buildingsByCode: self.buildingsByCode)
        self.pointsOfInterestForMap = self.pointsOfInterest.filter { poi in poi.visibleInMap }
        self.pointsOfInterestForList = self.pointsOfInterest.filter { poi in poi.visibleInList }
        self.buildingsForList = self.buildings.filter { poi in poi.visibleInList }
        self.locationsForList = self.locations.filter { loc in loc.visibleInList }
        self.locationsForMap = self.locations.filter { loc in loc.visibleInMap }
        self.locationsWithoutBuilding = self.locations.filter { loc in loc.building?.locationsForList.count == 1 && loc.visibleInList }
    }
    
    public static func fromData(_ data: Data) throws -> MapData {
        let decoder = JSONDecoder()
        let mapDataFile = try! decoder.decode(MapDataFile.self, from: data)
        return MapData(with: mapDataFile)
    }
}
