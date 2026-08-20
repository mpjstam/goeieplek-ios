import Foundation
import CoreLocation

/// Resolves a Google Maps share link (usually a shortened `maps.app.goo.gl` URL)
/// into a `PlaceSearchResult`. Reached only through `MapsLinkImport`, which owns
/// clipboard reading and deciding this is a Google (rather than Apple) link.
///
/// Google's share-link format isn't a documented API — this scrapes the resolved URL
/// for a coordinate pattern rather than relying on any stable contract, so it may need
/// updating if Google changes the format.
enum GoogleMapsLinkImport {
  static func isGoogleMapsHost(_ url: URL) -> Bool {
    guard let host = url.host?.lowercased() else { return false }
    return host.contains("google.") || host.contains("goo.gl")
  }

  static func resolve(url: URL) async throws -> PlaceSearchResult {
    guard isGoogleMapsHost(url) else {
      throw MapsLinkError.unrecognizedLink
    }

    // A full share link already carries the coordinates — resolving it over the
    // network first is both unnecessary and risky, since an unauthenticated request
    // can land on a cookie-consent redirect instead of the real page. Only genuinely
    // shortened `maps.app.goo.gl` links need that round trip.
    if let coordinate = coordinate(in: url.absoluteString) {
      return result(name: placeName(in: url.absoluteString), coordinate: coordinate)
    }

    // An unauthenticated request can land on Google's EU cookie-consent interstitial
    // (`consent.google.com/ml?continue=<the real URL>`) instead of the real page —
    // unwrap that before treating the response as the actual resolved destination.
    let resolved = unwrapConsentRedirect(try await resolvedURL(for: url))
    if let coordinate = coordinate(in: resolved.absoluteString) {
      return result(name: placeName(in: resolved.absoluteString), coordinate: coordinate)
    }

    // Some `maps.app.goo.gl` links resolve to an older URL shape that carries no
    // coordinate at all — just a human-readable name/address in `q=` and an opaque
    // Google place ID. Geocode that text with Apple's own search (already used
    // elsewhere for typed search) instead of giving up.
    if let query = searchableQuery(in: resolved.absoluteString),
       let best = try? await PlaceSearchService().search(query).first {
      return PlaceSearchResult(
        id: best.id,
        name: best.name,
        subtitle: "Vanuit Google Maps",
        latitude: best.latitude,
        longitude: best.longitude
      )
    }

    throw MapsLinkError.noCoordinatesFound
  }

  private static func result(name: String?, coordinate: CLLocationCoordinate2D) -> PlaceSearchResult {
    PlaceSearchResult(
      id: "google-maps-\(coordinate.latitude)-\(coordinate.longitude)",
      name: name ?? "Gedeelde locatie",
      subtitle: "Vanuit Google Maps",
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
  }

  // MARK: - Link detection

  /// `maps.app.goo.gl` links are shortened — the real URL (with coordinates) only
  /// appears after following the redirect, which `URLSession` does automatically.
  private static func resolvedURL(for url: URL) async throws -> URL {
    do {
      let (_, response) = try await URLSession.shared.data(from: url)
      return response.url ?? url
    } catch {
      throw MapsLinkError.networkFailure
    }
  }

  /// Unwraps Google's `consent.google.com/ml?continue=...` interstitial, which an
  /// unauthenticated (cookie-less) request can be redirected to instead of the real
  /// page. `continue` carries the actual destination, percent-encoded.
  private static func unwrapConsentRedirect(_ url: URL) -> URL {
    guard let host = url.host?.lowercased(), host.contains("consent.google"),
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let continueValue = components.queryItems?.first(where: { $0.name == "continue" })?.value,
          let target = URL(string: continueValue)
    else {
      return url
    }
    return target
  }

  // MARK: - Scraping the resolved URL

  private static func coordinate(in urlString: String) -> CLLocationCoordinate2D? {
    // The marker's precise coordinate, when present, beats the `@lat,lng` viewport center.
    if let match = firstMatch(pattern: #"!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)"#, in: urlString) {
      return CLLocationCoordinate2D(latitude: match.0, longitude: match.1)
    }
    if let match = firstMatch(pattern: #"@(-?\d+\.\d+),(-?\d+\.\d+)"#, in: urlString) {
      return CLLocationCoordinate2D(latitude: match.0, longitude: match.1)
    }
    if let match = firstMatch(pattern: #"[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)"#, in: urlString) {
      return CLLocationCoordinate2D(latitude: match.0, longitude: match.1)
    }
    return nil
  }

  private static func firstMatch(pattern: String, in text: String) -> (Double, Double)? {
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
          match.numberOfRanges >= 3,
          let latRange = Range(match.range(at: 1), in: text),
          let lngRange = Range(match.range(at: 2), in: text),
          let lat = Double(text[latRange]),
          let lng = Double(text[lngRange])
    else {
      return nil
    }
    return (lat, lng)
  }

  /// The `q=` parameter on the coordinate-less URL shape carries a human-readable
  /// name/address (e.g. `China+Palace+Restaurant,+De+Beurs+53,...`), suitable as a
  /// natural-language search query.
  private static func searchableQuery(in urlString: String) -> String? {
    guard let components = URLComponents(string: urlString),
          let rawValue = components.queryItems?.first(where: { $0.name == "q" })?.value,
          !rawValue.isEmpty
    else {
      return nil
    }
    return rawValue.replacingOccurrences(of: "+", with: " ")
  }

  private static func placeName(in urlString: String) -> String? {
    guard let range = urlString.range(of: "/maps/place/") else { return nil }
    let afterPlace = urlString[range.upperBound...]
    guard let end = afterPlace.firstIndex(of: "/") else { return nil }
    let encoded = String(afterPlace[..<end])
    // Order matters: Google's redirect re-encodes a literal "+" as "%2B", so decoding
    // first (then normalizing any resulting "+" to a space) handles both that and the
    // plain "+"-as-space convention some URLs use directly.
    let decoded = encoded.removingPercentEncoding ?? encoded
    return decoded.replacingOccurrences(of: "+", with: " ")
  }
}
