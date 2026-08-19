import Foundation
import CoreLocation

/// Resolves an Apple Maps share link into a `PlaceSearchResult`.
///
/// Apple's URL shape carries coordinates directly in the query string rather
/// than encoded into the path the way Google's does, and — aside from the
/// shortened `maps.apple` form — isn't itself a redirect, so most links here
/// resolve with no network round trip at all.
enum AppleMapsLinkImport {
  static func isAppleMapsHost(_ url: URL) -> Bool {
    guard let host = url.host?.lowercased() else { return false }
    return host == "maps.apple.com" || host == "maps.apple" || host.hasSuffix(".maps.apple.com")
  }

  static func resolve(url: URL) async throws -> PlaceSearchResult {
    guard isAppleMapsHost(url) else {
      throw MapsLinkError.unrecognizedLink
    }

    // `maps.apple` (no `.com`) is Apple's shortened form and needs its
    // redirect followed to reach the real `maps.apple.com` link.
    let resolvedURL = url.host?.lowercased() == "maps.apple"
      ? try await resolvedURL(for: url)
      : url

    let queryItems = URLComponents(url: resolvedURL, resolvingAgainstBaseURL: false)?.queryItems ?? []

    if let coordinate = coordinate(in: queryItems) {
      return result(name: name(in: queryItems), coordinate: coordinate)
    }

    // A link with no coordinate (or a `place` link missing `coordinate=`)
    // still usually carries a name or address — geocode that text with
    // Apple's own search instead of giving up.
    if let query = searchableQuery(in: queryItems),
       let best = try? await PlaceSearchService().search(query).first {
      return PlaceSearchResult(
        id: best.id,
        name: best.name,
        subtitle: "Vanuit Apple Maps",
        latitude: best.latitude,
        longitude: best.longitude
      )
    }

    throw MapsLinkError.noCoordinatesFound
  }

  private static func result(name: String?, coordinate: CLLocationCoordinate2D) -> PlaceSearchResult {
    PlaceSearchResult(
      id: "apple-maps-\(coordinate.latitude)-\(coordinate.longitude)",
      name: name ?? "Gedeelde locatie",
      subtitle: "From Apple Maps",
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
  }

  private static func resolvedURL(for url: URL) async throws -> URL {
    do {
      let (_, response) = try await URLSession.shared.data(from: url)
      return response.url ?? url
    } catch {
      throw MapsLinkError.networkFailure
    }
  }

  /// Apple Maps has used two query shapes over the years: the classic `ll=`
  /// (marker or viewport centre) and the newer `place`-endpoint `coordinate=`.
  private static func coordinate(in queryItems: [URLQueryItem]) -> CLLocationCoordinate2D? {
    for key in ["coordinate", "ll", "sll"] {
      if let raw = queryItems.first(where: { $0.name == key })?.value,
         let parsed = parseCoordinate(raw) {
        return parsed
      }
    }
    return nil
  }

  private static func parseCoordinate(_ raw: String) -> CLLocationCoordinate2D? {
    let parts = raw.split(separator: ",")
    guard parts.count == 2,
          let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
          let lng = Double(parts[1].trimmingCharacters(in: .whitespaces))
    else { return nil }
    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
  }

  /// `name=` (place endpoint) or `q=` (classic) carries the human-readable title.
  private static func name(in queryItems: [URLQueryItem]) -> String? {
    for key in ["name", "q"] {
      if let raw = queryItems.first(where: { $0.name == key })?.value, !raw.isEmpty {
        return raw.replacingOccurrences(of: "+", with: " ")
      }
    }
    return nil
  }

  private static func searchableQuery(in queryItems: [URLQueryItem]) -> String? {
    if let named = name(in: queryItems) { return named }
    if let address = queryItems.first(where: { $0.name == "address" })?.value, !address.isEmpty {
      return address.replacingOccurrences(of: "+", with: " ")
    }
    return nil
  }
}
