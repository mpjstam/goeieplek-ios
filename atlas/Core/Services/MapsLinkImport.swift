import Foundation
import UIKit

enum MapsLinkError: LocalizedError {
  case clipboardEmpty
  case unrecognizedLink
  case networkFailure
  case noCoordinatesFound
  case noPendingShare

  var errorDescription: String? {
    switch self {
    case .clipboardEmpty:
      return "Kopieer eerst een locatielink vanuit Apple Maps of Google Maps en probeer het opnieuw."
    case .unrecognizedLink:
      return "Dat lijkt geen link van Apple Maps of Google Maps te zijn."
    case .networkFailure:
      return "Kon die link niet openen. Controleer je verbinding en probeer het opnieuw."
    case .noCoordinatesFound:
      return "Kon geen locatie vinden in die link."
    case .noPendingShare:
      return "Kon geen gedeelde locatie vinden. Probeer opnieuw te delen."
    }
  }
}

/// Resolves a shared map link — Apple Maps or Google Maps — from the clipboard
/// or an explicit URL into a `PlaceSearchResult`.
///
/// This is the one entry point the rest of the app calls (the "Paste from
/// Maps" row, and the share-extension hand-off via `MapsShareInbox`); it
/// just dispatches to whichever service's own importer recognizes the link.
/// The per-service parsing — coordinate formats, redirects, coordinate-less
/// fallbacks — stays in `AppleMapsLinkImport` and `GoogleMapsLinkImport`,
/// since the two services' URL shapes have nothing in common.
enum MapsLinkImport {
  static func resolveFromClipboard() async throws -> PlaceSearchResult {
    let candidates = candidateURLs()
    guard !candidates.isEmpty else {
      throw MapsLinkError.clipboardEmpty
    }
    // `.url` and `.string` can each carry a different link (e.g. an app-scheme
    // URL alongside the real web link) — prefer whichever candidate actually
    // looks like a recognized maps host over just the first one.
    guard let url = candidates.first(where: isRecognizedHost) else {
      throw MapsLinkError.unrecognizedLink
    }
    return try await resolve(url: url)
  }

  /// Resolves an explicit maps URL, bypassing the clipboard — used by the
  /// "paste" flow above once it has picked a candidate, and by the share
  /// extension hand-off in `MapsShareInbox`.
  static func resolve(url: URL) async throws -> PlaceSearchResult {
    if AppleMapsLinkImport.isAppleMapsHost(url) {
      return try await AppleMapsLinkImport.resolve(url: url)
    }
    if GoogleMapsLinkImport.isGoogleMapsHost(url) {
      return try await GoogleMapsLinkImport.resolve(url: url)
    }
    throw MapsLinkError.unrecognizedLink
  }

  private static func isRecognizedHost(_ url: URL) -> Bool {
    AppleMapsLinkImport.isAppleMapsHost(url) || GoogleMapsLinkImport.isGoogleMapsHost(url)
  }

  /// A share sheet can populate the pasteboard's URL slot with a different
  /// value than its plain-text slot (e.g. an app-scheme URL alongside the
  /// real web link) — collect both instead of trusting one.
  private static func candidateURLs() -> [URL] {
    var urls: [URL] = []
    if let url = UIPasteboard.general.url {
      urls.append(url)
    }
    if let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
       !text.isEmpty,
       let detected = firstURL(in: text) {
      urls.append(detected)
    }
    return urls
  }

  private static func firstURL(in text: String) -> URL? {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let range = NSRange(text.startIndex..., in: text)
    if let match = detector?.firstMatch(in: text, range: range), let url = match.url {
      return url
    }
    return URL(string: text)
  }
}
