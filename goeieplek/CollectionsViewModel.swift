import Foundation
import SwiftData
import Observation

@Observable
class CollectionsViewModel {
  var collections: [Collection] = []
  var isLoading = false
  var error: String?

  private let repository: CollectionsRepository

  init(modelContext: ModelContext) {
    self.repository = CollectionsRepository(modelContext: modelContext)
    loadCollections()
  }

  func loadCollections() {
    isLoading = true
    do {
      collections = try repository.fetchCollections()
      error = nil
    } catch {
      self.error = error.localizedDescription
    }
    isLoading = false
  }

  func createCollection(name: String, notes: String = "") {
    do {
      _ = try repository.createCollection(name: name, notes: notes)
      loadCollections()
    } catch {
      self.error = error.localizedDescription
    }
  }

  func deleteCollection(_ collection: Collection) {
    do {
      try repository.deleteCollection(collection)
      loadCollections()
    } catch {
      self.error = error.localizedDescription
    }
  }
}
