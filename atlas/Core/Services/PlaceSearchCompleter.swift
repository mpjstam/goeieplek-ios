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
    case .expiredSuggestion: "Deze suggestie is niet meer beschikbaar. Probeer opnieuw te zoeken."
    case .noResult: "Kon geen locatie vinden voor deze suggestie."
    }
  }
}

/// Live, incremental search suggestions as the user types, backed by
/// `MKLocalSearchCompleter` — the same API behind Apple Maps' own search bar,
/// and noticeably better than a plain `MKLocalSearch` at matching a business
/// name from a short/partial fragment (e.g. "semarang" finding "Toko
/// Semarang"). Used as `SearchTabView`'s primary suggestion source, with a
/// debounced `PlaceSearchService` search running alongside it as a fallback —
/// see `SearchTabView.scheduleSearch`.
///
/// A real-device `MKLocalSearchCompleter` has been observed to fail once
/// (`MKErrorDomain` error 5) and then silently stop returning results for the
/// rest of the session. `rebuildCompleter()` recreates the underlying object
/// from scratch after any failure instead of trusting the same instance to
/// recover on its own — cheap, and removes whatever internal state a failure
/// leaves behind as the suspect.
@Observable
final class PlaceSearchCompleter: NSObject {
  private(set) var suggestions: [PlaceSearchSuggestion] = []

  private var completer: MKLocalSearchCompleter
  private var completionsByID: [String: MKLocalSearchCompletion] = [:]
  /// The fragment last set — reapplied when the completer is rebuilt after an
  /// error, so a self-heal mid-query doesn't drop what the user already typed.
  private var currentQueryFragment = ""

  override init() {
    completer = Self.makeCompleter()
    super.init()
    completer.delegate = self
  }

  var queryFragment: String {
    get { currentQueryFragment }
    set {
      currentQueryFragment = newValue
      completer.queryFragment = newValue
    }
  }

  /// Mirrors `MKLocalSearchCompleter.isSearching` — lets `SearchTabView` show
  /// a "still searching" state instead of a bare, ambiguous empty list while
  /// a debounced query is in flight.
  var isSearching: Bool { completer.isSearching }

  func clear() {
    currentQueryFragment = ""
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

  private static func makeCompleter() -> MKLocalSearchCompleter {
    let completer = MKLocalSearchCompleter()
    completer.resultTypes = [.pointOfInterest, .address]
    completer.region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 52.1, longitude: 5.3),
      span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    )
    return completer
  }

  private func rebuildCompleter() {
    let fresh = Self.makeCompleter()
    fresh.delegate = self
    completer = fresh
    if !currentQueryFragment.isEmpty {
      fresh.queryFragment = currentQueryFragment
    }
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
    rebuildCompleter()
  }
}
