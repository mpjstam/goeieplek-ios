import Foundation
import CoreLocation

/// Builds universal-link URLs that hand a coordinate off to Apple Maps or
/// Google Maps for turn-by-turn directions. Universal links (rather than the
/// `maps://` / `comgooglemaps://` app-schemes) need no `LSApplicationQueriesSchemes`
/// entry and degrade gracefully to the web app when the native app isn't
/// installed, so there's nothing to declare and nothing that can silently fail.
enum MapsDirectionsLink {
  static func appleMaps(to coordinate: CLLocationCoordinate2D, name: String) -> URL {
    var components = URLComponents(string: "https://maps.apple.com/")!
    components.queryItems = [
      URLQueryItem(name: "daddr", value: "\(coordinate.latitude),\(coordinate.longitude)"),
      URLQueryItem(name: "q", value: name),
      URLQueryItem(name: "dirflg", value: "d"),
    ]
    return components.url!
  }

  static func googleMaps(to coordinate: CLLocationCoordinate2D) -> URL {
    var components = URLComponents(string: "https://www.google.com/maps/dir/")!
    components.queryItems = [
      URLQueryItem(name: "api", value: "1"),
      URLQueryItem(name: "destination", value: "\(coordinate.latitude),\(coordinate.longitude)"),
      URLQueryItem(name: "travelmode", value: "driving"),
    ]
    return components.url!
  }
}
