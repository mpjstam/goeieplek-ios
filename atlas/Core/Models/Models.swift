import Foundation
import SwiftData
import MapKit

@Model
final class Collection: Hashable {
  var id: String = UUID().uuidString
  var name: String = ""
  var notes: String = ""
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now

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

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Collection, rhs: Collection) -> Bool {
    lhs.id == rhs.id
  }
}

@Model
final class Category: Hashable {
  var id: String = UUID().uuidString
  var name: String = ""
  var sortOrder: Int = 0
  var createdAt: Date = Date.now

  init(
    id: String = UUID().uuidString,
    name: String,
    sortOrder: Int = 0,
    createdAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.sortOrder = sortOrder
    self.createdAt = createdAt
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Category, rhs: Category) -> Bool {
    lhs.id == rhs.id
  }
}

@Model
final class Place: Hashable {
  var id: String = UUID().uuidString
  var name: String = ""
  var notes: String = ""
  var latitude: Double = 0
  var longitude: Double = 0
  var category: String = "overig"
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now

  @Relationship(deleteRule: .cascade, inverse: \Photo.place) var photos: [Photo] = []
  var collection: Collection?

  init(
    id: String = UUID().uuidString,
    name: String,
    notes: String = "",
    latitude: Double,
    longitude: Double,
    category: String = "overig",
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

  /// Up to `Photo.maxPerPlace` photos, in display order.
  var sortedPhotos: [Photo] {
    photos.sorted { $0.sortOrder < $1.sortOrder }
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Place, rhs: Place) -> Bool {
    lhs.id == rhs.id
  }
}

@Model
final class Photo: Hashable {
  /// Places show up to this many photos; enforced by callers (the picker UI and
  /// the repository), not by SwiftData itself.
  static let maxPerPlace = 5

  var id: String = UUID().uuidString
  @Attribute(.externalStorage) var data: Data = Data()
  var sortOrder: Int = 0
  var place: Place?

  init(id: String = UUID().uuidString, data: Data, sortOrder: Int = 0) {
    self.id = id
    self.data = data
    self.sortOrder = sortOrder
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Photo, rhs: Photo) -> Bool {
    lhs.id == rhs.id
  }
}
