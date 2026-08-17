import Foundation
import CoreLocation
import MapKit

enum LocationError: LocalizedError {
  case permissionDenied
  case unavailable

  var errorDescription: String? {
    switch self {
    case .permissionDenied:
      return "Location access is off for Goeieplek. Turn it on in Settings to use your current location."
    case .unavailable:
      return "Couldn't determine your location. Try again in a moment."
    }
  }
}

/// Resolves the device's current location into a `PlaceSearchResult`, so "use my
/// current location" can flow through the exact same preview/confirm/add path as a
/// typed search result — no separate UI branch needed.
@MainActor
final class CurrentLocationService: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var authorizationContinuation: CheckedContinuation<Void, Error>?
  private var locationContinuation: CheckedContinuation<CLLocation, Error>?

  override init() {
    super.init()
    manager.delegate = self
  }

  func currentPlace() async throws -> PlaceSearchResult {
    try await requestAuthorizationIfNeeded()
    let location = try await requestLocation()
    let name = await reverseGeocodedName(for: location) ?? "Current Location"
    return PlaceSearchResult(
      id: "current-location-\(location.coordinate.latitude)-\(location.coordinate.longitude)",
      name: name,
      subtitle: "Current location",
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude
    )
  }

  // MARK: - Authorization

  private func requestAuthorizationIfNeeded() async throws {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      return
    case .denied, .restricted:
      throw LocationError.permissionDenied
    case .notDetermined:
      authorizationContinuation?.resume(throwing: CancellationError())
      try await withCheckedThrowingContinuation { continuation in
        authorizationContinuation = continuation
        manager.requestWhenInUseAuthorization()
      }
    @unknown default:
      throw LocationError.unavailable
    }
  }

  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    Task { @MainActor in
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        authorizationContinuation?.resume()
      case .denied, .restricted:
        authorizationContinuation?.resume(throwing: LocationError.permissionDenied)
      case .notDetermined:
        return // still waiting on the user's choice
      @unknown default:
        authorizationContinuation?.resume(throwing: LocationError.unavailable)
      }
      authorizationContinuation = nil
    }
  }

  // MARK: - Location

  private func requestLocation() async throws -> CLLocation {
    locationContinuation?.resume(throwing: CancellationError())
    return try await withCheckedThrowingContinuation { continuation in
      locationContinuation = continuation
      manager.requestLocation()
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    Task { @MainActor in
      if let location = locations.first {
        locationContinuation?.resume(returning: location)
      } else {
        locationContinuation?.resume(throwing: LocationError.unavailable)
      }
      locationContinuation = nil
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task { @MainActor in
      locationContinuation?.resume(throwing: error)
      locationContinuation = nil
    }
  }

  // MARK: - Reverse geocoding

  /// Best-effort. A missing or failed lookup falls back to "Current Location"
  /// in `currentPlace()` rather than failing the whole capture.
  private func reverseGeocodedName(for location: CLLocation) async -> String? {
    guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
    guard let item = try? await request.mapItems.first else { return nil }
    return item.name
  }
}
