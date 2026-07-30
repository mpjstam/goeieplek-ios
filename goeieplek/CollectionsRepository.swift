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

  func addPlace(to collection: Collection, name: String, notes: String, latitude: Double, longitude: Double, category: String = "other") throws -> Place {
    let place = Place(name: name, notes: notes, latitude: latitude, longitude: longitude, category: category)
    place.collection = collection
    collection.places.append(place)
    modelContext.insert(place)
    try modelContext.save()
    return place
  }

  func updatePlace(_ place: Place, name: String, notes: String, category: String) throws {
    place.name = name
    place.notes = notes
    place.category = category
    place.updatedAt = .now
    try modelContext.save()
  }

  func deletePlace(_ place: Place) throws {
    modelContext.delete(place)
    try modelContext.save()
  }
}
