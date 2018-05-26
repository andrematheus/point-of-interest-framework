import Foundation
import CoreLocation

public enum FeatureType: String, Codable {
    case Feature
}

public enum Coordinates {
    case Point(CLLocationCoordinate2D)
    case Polygon([[CLLocationCoordinate2D]])
    case Unsupported
}

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

public struct FeatureGeometry {
    var coordinates: Coordinates
    var type: String
}

extension FeatureGeometry: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self.coordinates {
        case .Point(let coordinates):
            try container.encode("point", forKey: .type)
            try container.encode(coordinates, forKey: .coordinates)
        case .Polygon(let coordinates):
            try container.encode("polygon", forKey: .type)
            try container.encode(coordinates, forKey: .coordinates)
        default:
            try container.encode("unknown", forKey: .type)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        let coords: Coordinates
        switch type {
        case "Point":
            let payload = try container.decode(CLLocationCoordinate2D.self, forKey: CodingKeys.coordinates)
            coords = .Point(payload)
        case "Polygon":
            let payload = try container.decode([[CLLocationCoordinate2D]].self, forKey: CodingKeys.coordinates)
            coords = .Polygon(payload)
        default:
            coords = .Unsupported
        }
        self = FeatureGeometry(coordinates: coords, type: type)
    }
}

public struct Feature: Codable {
    var type: FeatureType
    var properties: [String: String]
    var geometry: FeatureGeometry
    var id: String
}

public struct GeoJsonFile: Codable {
    var features: [Feature]
    var type: String
}
