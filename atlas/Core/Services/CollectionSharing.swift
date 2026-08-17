import Foundation
import UniformTypeIdentifiers
import CoreTransferable

/// A place inside a shared collection file. Mirrors `Place`'s user-facing fields;
/// deliberately excludes ids/dates, which belong to the receiving library, not the
/// place itself.
nonisolated struct SharedPlace: Codable {
  var name: String
  var notes: String
  var latitude: Double
  var longitude: Double
  var category: String
  var photoDatas: [Data]
}

extension SharedPlace {
  init(_ place: Place) {
    self.init(
      name: place.name,
      notes: place.notes,
      latitude: place.latitude,
      longitude: place.longitude,
      category: place.category,
      photoDatas: place.sortedPhotos.map(\.data)
    )
  }
}

/// The file format for "share as Atlas file": a full, re-importable snapshot of a
/// collection. `schema` lets `decode(from:)` reject unrelated `.json` files instead
/// of importing garbage.
nonisolated struct SharedCollection: Codable {
  static let schemaIdentifier = "studiostam.atlas.collection.v1"

  var schema = SharedCollection.schemaIdentifier
  var name: String
  var notes: String
  var places: [SharedPlace]
}

extension SharedCollection {
  init(_ collection: Collection) {
    self.init(
      name: collection.name,
      notes: collection.notes,
      places: collection.places.map(SharedPlace.init)
    )
  }
}

enum CollectionImportError: LocalizedError {
  case invalidFile

  var errorDescription: String? {
    "Couldn't read this file. Make sure it's a collection shared from Goeieplek."
  }
}

/// Export-only `Transferable` conformance backing `ShareLink`. Using the system
/// `.json` content type (rather than a custom UTType) means no Info.plist document-type
/// declarations are needed — those require array-valued Info.plist keys, which this
/// project's build-settings-generated Info.plist can't express (see `AtlasFont.register()`).
nonisolated extension SharedCollection: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .json) { shared in
      try JSONEncoder().encode(shared)
    }
    .suggestedFileName { shared in
      let trimmed = shared.name.trimmingCharacters(in: .whitespacesAndNewlines)
      let safeName = (trimmed.isEmpty ? "Collection" : trimmed)
        .replacingOccurrences(of: "/", with: "-")
      return "\(safeName).atlascollection.json"
    }
  }

  static func decode(from url: URL) throws -> SharedCollection {
    guard let data = try? Data(contentsOf: url),
          let shared = try? JSONDecoder().decode(SharedCollection.self, from: data),
          shared.schema == schemaIdentifier
    else {
      throw CollectionImportError.invalidFile
    }
    return shared
  }
}

/// The file format for "back up everything": every collection in one file, so
/// restoring after data loss (a new phone, a deleted app) is a single import
/// rather than one per collection. Deliberately reuses `SharedCollection` for
/// each entry rather than a parallel format — a library backup is just "all
/// collections," nothing more.
nonisolated struct SharedLibrary: Codable {
  static let schemaIdentifier = "studiostam.atlas.library.v1"

  var schema = SharedLibrary.schemaIdentifier
  var collections: [SharedCollection]
}

extension SharedLibrary {
  init(_ collections: [Collection]) {
    self.init(collections: collections.map(SharedCollection.init))
  }
}

nonisolated extension SharedLibrary: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .json) { shared in
      try JSONEncoder().encode(shared)
    }
    .suggestedFileName { shared in
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return "Goeieplek Backup \(formatter.string(from: .now)).atlaslibrary.json"
    }
  }

  static func decode(from url: URL) throws -> SharedLibrary {
    guard let data = try? Data(contentsOf: url),
          let shared = try? JSONDecoder().decode(SharedLibrary.self, from: data),
          shared.schema == schemaIdentifier
    else {
      throw CollectionImportError.invalidFile
    }
    return shared
  }
}
