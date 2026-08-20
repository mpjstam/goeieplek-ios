import Foundation
import MapKit

/// A single external search hit, decoupled from MapKit.
///
/// Keeping `MKMapItem` out of the views means the deprecated-API surface lives in
/// exactly one file, and the views stay testable without MapKit.
struct PlaceSearchResult: Identifiable, Hashable {
  let id: String
  let name: String
  let subtitle: String
  let latitude: Double
  let longitude: Double

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

/// Wraps `MKLocalSearch` for finding places that are not yet in the library
/// (the "external search" of `Architecture.md`).
struct PlaceSearchService {

  /// Bias results towards this region when the device location is unknown.
  private let fallbackRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 52.1, longitude: 5.3),
    span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
  )

  func search(_ query: String) async throws -> [PlaceSearchResult] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return [] }

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = trimmed
    request.region = fallbackRegion

    let response = try await MKLocalSearch(request: request).start()
    return response.mapItems.map(Self.result(from:))
  }

  /// Internal access rather than `private` — `PlaceSearchCompleter` reuses this
  /// to convert the one `MKLocalSearch` it performs (resolving a completion the
  /// user picked) into the same result type, rather than duplicating the mapping.
  static func result(from item: MKMapItem) -> PlaceSearchResult {
    let coordinate = item.location.coordinate
    return PlaceSearchResult(
      id: item.identifier?.rawValue ?? "\(coordinate.latitude),\(coordinate.longitude)",
      name: item.name ?? "Onbekende plek",
      subtitle: item.address?.shortAddress ?? "",
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
  }
}
