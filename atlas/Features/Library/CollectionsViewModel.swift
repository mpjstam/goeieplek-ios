import Foundation
import SwiftData
import Observation
import UIKit

@Observable
class CollectionsViewModel {
  var collections: [Collection] = []
  var isLoading = false
  var error: String?

  private let repository: CollectionsRepository
  private var coverImageCache: [String: UIImage] = [:]

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
    // Cleared rather than kept across reloads: a cached cover could otherwise
    // go stale if a collection's photos changed since it was last decoded.
    coverImageCache.removeAll()
  }

  /// The first photo belonging to any place in the collection — places are
  /// checked in their stored order, and each place's own photos in display
  /// order (`sortedPhotos`), so this is stable rather than picking a random
  /// cover shot. Cached per collection for the lifetime of the current
  /// `collections` list, since decoding a full photo from raw `Data` isn't
  /// cheap to repeat on every row re-render.
  func coverImage(for collection: Collection) -> UIImage? {
    if let cached = coverImageCache[collection.id] {
      return cached
    }
    for place in collection.places {
      if let data = place.sortedPhotos.first?.data, let image = UIImage(data: data) {
        coverImageCache[collection.id] = image
        return image
      }
    }
    return nil
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

  /// Recreates a shared collection and its places locally. Any place category the
  /// receiving library doesn't already have is added, so imported places stay
  /// editable (their category still appears in the segmented picker) instead of
  /// carrying a name nothing else recognizes.
  func importCollection(_ shared: SharedCollection, categoriesRepository: CategoriesRepository) {
    do {
      let collection = try repository.createCollection(name: shared.name, notes: shared.notes)
      var knownCategories = Set((try? categoriesRepository.fetchCategories())?.map { $0.name.lowercased() } ?? [])
      for place in shared.places {
        _ = try repository.addPlace(
          to: collection,
          name: place.name,
          notes: place.notes,
          latitude: place.latitude,
          longitude: place.longitude,
          category: place.category,
          photoDatas: place.photoDatas
        )
        let key = place.category.lowercased()
        if !knownCategories.contains(key) {
          _ = try? categoriesRepository.addCategory(name: place.category)
          knownCategories.insert(key)
        }
      }
      loadCollections()
    } catch {
      self.error = error.localizedDescription
    }
  }

  /// Restores a full-library backup by importing each of its collections in turn.
  /// Always creates new collections rather than merging into existing ones with
  /// the same name — safe for the "lost my phone, restoring fresh" case this
  /// exists for, and no worse than the existing single-collection import for the
  /// "already have this data" case.
  func importLibrary(_ shared: SharedLibrary, categoriesRepository: CategoriesRepository) {
    for collection in shared.collections {
      importCollection(collection, categoriesRepository: categoriesRepository)
    }
  }
}
