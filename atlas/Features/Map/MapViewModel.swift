import Foundation
import SwiftData
import Observation
import OSLog

/// Presentation state for the Map tab.
///
/// Reads through `CollectionsRepository` rather than querying SwiftData directly,
/// per the repository rule in `Architecture.md`.
@Observable
final class MapViewModel {
  private(set) var places: [Place] = []
  private(set) var collectionCount = 0
  private(set) var categories: [String] = []

  /// `nil` means "All categories".
  var selectedCategory: String?

  private let collections: CollectionsRepository
  private let categoriesRepository: CategoriesRepository

  init(modelContext: ModelContext) {
    self.collections = CollectionsRepository(modelContext: modelContext)
    self.categoriesRepository = CategoriesRepository(modelContext: modelContext)
  }

  /// Places matching the active category filter.
  var visiblePlaces: [Place] {
    guard let selectedCategory else { return places }
    return places.filter { $0.category == selectedCategory }
  }

  var filterLabel: String {
    selectedCategory?.capitalized ?? "All categories"
  }

  var summary: String {
    let count = visiblePlaces.count
    return count == 1 ? "1 place" : "\(count) places"
  }

  var subtitle: String {
    collectionCount == 1 ? "across 1 collection" : "across \(collectionCount) collections"
  }

  func load() {
    do {
      let all = try collections.fetchCollections()
      collectionCount = all.count
      places = all.flatMap(\.places)
      categories = try categoriesRepository.fetchCategories().map(\.name)

      // Drop a filter whose category has since been deleted or renamed.
      if let selected = selectedCategory, !categories.contains(selected) {
        selectedCategory = nil
      }
    } catch {
      AtlasLog.map.error("Failed to load map data: \(error.localizedDescription, privacy: .public)")
    }
  }
}
