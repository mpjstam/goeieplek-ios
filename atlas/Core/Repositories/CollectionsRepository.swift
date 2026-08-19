import Foundation
import SwiftData

class CollectionsRepository {
  private let modelContext: ModelContext

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  func fetchCollections() throws -> [Collection] {
    var descriptor = FetchDescriptor<Collection>()
    descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
    return try modelContext.fetch(descriptor)
  }

  func createCollection(name: String, notes: String = "") throws -> Collection {
    let collection = Collection(name: name, notes: notes)
    modelContext.insert(collection)
    try modelContext.save()
    return collection
  }

  func updateCollection(_ collection: Collection, name: String, notes: String) throws {
    collection.name = name
    collection.notes = notes
    collection.updatedAt = .now
    try modelContext.save()
  }

  func deleteCollection(_ collection: Collection) throws {
    modelContext.delete(collection)
    try modelContext.save()
  }

  func addPlace(to collection: Collection, name: String, notes: String, latitude: Double, longitude: Double, category: String = "overig", photoDatas: [Data] = []) throws -> Place {
    let place = Place(name: name, notes: notes, latitude: latitude, longitude: longitude, category: category)
    place.collection = collection
    collection.places.append(place)
    modelContext.insert(place)
    addPhotos(photoDatas, to: place)
    try modelContext.save()
    return place
  }

  func updatePlace(_ place: Place, name: String, notes: String, category: String, photoDatas: [Data]) throws {
    place.name = name
    place.notes = notes
    place.category = category
    place.updatedAt = .now
    for photo in place.photos {
      modelContext.delete(photo)
    }
    place.photos.removeAll()
    addPhotos(photoDatas, to: place)
    try modelContext.save()
  }

  /// Caps at `Photo.maxPerPlace` even if a caller (e.g. importing a shared
  /// collection file) hands over more.
  private func addPhotos(_ photoDatas: [Data], to place: Place) {
    for (index, data) in photoDatas.prefix(Photo.maxPerPlace).enumerated() {
      let photo = Photo(data: data, sortOrder: index)
      photo.place = place
      place.photos.append(photo)
      modelContext.insert(photo)
    }
  }

  func deletePlace(_ place: Place) throws {
    modelContext.delete(place)
    try modelContext.save()
  }

  func movePlace(_ place: Place, to newCollection: Collection) throws {
    guard place.collection?.id != newCollection.id else { return }
    place.collection?.places.removeAll { $0.id == place.id }
    place.collection = newCollection
    newCollection.places.append(place)
    place.updatedAt = .now
    try modelContext.save()
  }
}
