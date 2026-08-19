import Foundation
import SwiftData

enum CategoryError: LocalizedError {
  case cannotDeleteLastCategory
  case duplicateName

  var errorDescription: String? {
    switch self {
    case .cannotDeleteLastCategory:
      return "Je hebt minstens één categorie nodig."
    case .duplicateName:
      return "Er bestaat al een categorie met die naam."
    }
  }
}

class CategoriesRepository {
  private let modelContext: ModelContext

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  func fetchCategories() throws -> [Category] {
    var descriptor = FetchDescriptor<Category>()
    descriptor.sortBy = [SortDescriptor(\.sortOrder)]
    return try modelContext.fetch(descriptor)
  }

  func seedDefaultsIfNeeded() throws {
    guard try fetchCategories().isEmpty else { return }
    let defaults = ["restaurant", "hotel", "uitzicht", "activiteit", "parkeren", "overig"]
    for (index, name) in defaults.enumerated() {
      modelContext.insert(Category(name: name, sortOrder: index))
    }
    try modelContext.save()
  }

  @discardableResult
  func addCategory(name: String) throws -> Category {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let existing = try fetchCategories()
    guard !existing.contains(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
      throw CategoryError.duplicateName
    }
    let maxOrder = existing.map(\.sortOrder).max() ?? -1
    let category = Category(name: trimmed, sortOrder: maxOrder + 1)
    modelContext.insert(category)
    try modelContext.save()
    return category
  }

  func renameCategory(_ category: Category, to newName: String) throws {
    let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
    let existing = try fetchCategories()
    guard !existing.contains(where: { $0.id != category.id && $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
      throw CategoryError.duplicateName
    }

    let oldName = category.name
    category.name = trimmed

    let affectedPlaces = try modelContext.fetch(
      FetchDescriptor<Place>(predicate: #Predicate { $0.category == oldName })
    )
    for place in affectedPlaces {
      place.category = trimmed
    }
    try modelContext.save()
  }

  func deleteCategory(_ category: Category) throws {
    let remaining = try fetchCategories().filter { $0.id != category.id }
    guard let fallback = remaining.first else {
      throw CategoryError.cannotDeleteLastCategory
    }

    let name = category.name
    let fallbackName = fallback.name
    let affectedPlaces = try modelContext.fetch(
      FetchDescriptor<Place>(predicate: #Predicate { $0.category == name })
    )
    for place in affectedPlaces {
      place.category = fallbackName
    }

    modelContext.delete(category)
    try modelContext.save()
  }
}
