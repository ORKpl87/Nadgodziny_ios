import Foundation
import CoreLocation

struct Overtime: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let date: Date
    var hours: Double
    var description: String
    var city: String
    var coordinates: CLLocationCoordinate2D?
    
    init(id: UUID = UUID(), userId: UUID, date: Date = Date(), 
         hours: Double = 0.0, description: String = "", city: String = "", 
         coordinates: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.userId = userId
        self.date = date
        self.hours = hours
        self.description = description
        self.city = city
        self.coordinates = coordinates
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, date, hours, description, city
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        date = try container.decode(Date.self, forKey: .date)
        hours = try container.decode(Double.self, forKey: .hours)
        description = try container.decode(String.self, forKey: .description)
        city = try container.decode(String.self, forKey: .city)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinates = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(date, forKey: .date)
        try container.encode(hours, forKey: .hours)
        try container.encode(description, forKey: .description)
        try container.encode(city, forKey: .city)
        
        if let coordinates = coordinates {
            try container.encode(coordinates.latitude, forKey: .latitude)
            try container.encode(coordinates.longitude, forKey: .longitude)
        }
    }
} 