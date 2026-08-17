import Foundation
import MapKit
import Observation
import OSLog

/// A lightweight, unresolved search suggestion — no coordinate yet. Resolving
/// one costs a real network round trip (see `PlaceSearchCompleter.resolve`), so
/// that only happens once, when the user actually picks a suggestion.
struct PlaceSearchSuggestion: Identifiable {
  /// Derived from the content itself rather than an index, so it stays valid
  /// across completer updates as long as the suggestion's text hasn't changed.
  var id: String { "\(title)|\(subtitle)" }
  let title: String
  let subtitle: String
  /// Ranges within `title` that matched the typed query, for bolding — the
  /// same highlighting Spotlight/Maps show in their own suggestion lists.
  let titleHighlightRanges: [NSRange]
}

enum PlaceSearchCompleterError: LocalizedError {
  case expiredSuggestion
  case noResult

  var errorDescription: String? {
    switch self {
    case .expiredSuggestion: "That suggestion is no longer available. Try searching again."
    case .noResult: "Couldn't find a location for that suggestion."
    }
  }
}

/// Live, incremental search suggestions as the user types, backed by
/// `MKLocalSearchCompleter` — the same API behind Apple Maps' own search bar.
///
/// `PlaceSearchService.search` resolves full coordinates on every call, which
/// is the wrong tool for a search-as-you-type field: it's a heavier request
/// than a suggestion list needs, and firing one per keystroke burns quota for
/// no benefit until the user actually picks something. The completer instead
/// pushes back cheap title/subtitle suggestions as text changes, and only the
/// one the user taps gets resolved to a coordinate.
@Observable
final class PlaceSearchCompleter: NSObject {
  private(set) var suggestions: [PlaceSearchSuggestion] = []

  private let completer: MKLocalSearchCompleter
  private var completionsByID: [String: MKLocalSearchCompletion] = [:]

  override init() {
    completer = MKLocalSearchCompleter()
    super.init()
    completer.resultTypes = [.pointOfInterest, .address]
    completer.region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 52.1, longitude: 5.3),
      span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    )
    completer.delegate = self
  }

  var queryFragment: String {
    get { completer.queryFragment }
    set { completer.queryFragment = newValue }
  }

  func clear() {
    completer.queryFragment = ""
    completionsByID.removeAll()
    suggestions = []
  }

  /// The one full-cost `MKLocalSearch` in this flow, deferred until the user
  /// actually picks a suggestion rather than fired on every keystroke.
  func resolve(_ suggestion: PlaceSearchSuggestion) async throws -> PlaceSearchResult {
    guard let completion = completionsByID[suggestion.id] else {
      throw PlaceSearchCompleterError.expiredSuggestion
    }
    let request = MKLocalSearch.Request(completion: completion)
    let response = try await MKLocalSearch(request: request).start()
    guard let item = response.mapItems.first else {
      throw PlaceSearchCompleterError.noResult
    }
    return PlaceSearchService.result(from: item)
  }
}

extension PlaceSearchCompleter: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    completionsByID.removeAll()
    suggestions = completer.results.map { completion in
      let suggestion = PlaceSearchSuggestion(
        title: completion.title,
        subtitle: completion.subtitle,
        titleHighlightRanges: completion.titleHighlightRanges.map(\.rangeValue)
      )
      completionsByID[suggestion.id] = completion
      return suggestion
    }
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    AtlasLog.search.error("Search completer failed: \(error.localizedDescription, privacy: .public)")
    suggestions = []
  }
}
