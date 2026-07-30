import Foundation
import SwiftData
import MapKit

@Model
final class Collection {
  @Attribute(.unique) var id: String
  var name: String
  var notes: String
  var createdAt: Date
  var updatedAt: Date

  @Relationship(deleteRule: .cascade, inverse: \Place.collection) var places: [Place] = []

  init(
    id: String = UUID().uuidString,
    name: String,
    notes: String = "",
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.notes = notes
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

@Model
final class Place {
  @Attribute(.unique) var id: String
  var name: String
  var notes: String
  var latitude: Double
  var longitude: Double
  var category: String
  var createdAt: Date
  var updatedAt: Date

  var collection: Collection?

  init(
    id: String = UUID().uuidString,
    name: String,
    notes: String = "",
    latitude: Double,
    longitude: Double,
    category: String = "other",
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.notes = notes
    self.latitude = latitude
    self.longitude = longitude
    self.category = category
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
