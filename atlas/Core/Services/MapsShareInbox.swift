import Foundation

/// Reads back whatever `AtlasShare`'s `ShareViewController` dropped in the App
/// Group container — an Apple Maps or Google Maps link. The extension can't
/// reliably switch back to Atlas itself (see its doc comment), so this is
/// polled by `RootView` on every activation instead of waiting on a deep link
/// that might not arrive.
enum MapsShareInbox {
  private static let appGroupID = "group.studiostam.atlas"
  private static let pendingURLKey = "pendingMapsShareURL"

  /// Returns and clears the pending share, if any. `nil` covers both "nothing
  /// was shared" and "the App Group container isn't reachable" — either way
  /// there's nothing for the caller to act on.
  static func takePending() -> String? {
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      return nil
    }
    let fileURL = containerURL.appendingPathComponent(pendingURLKey).appendingPathExtension("txt")
    guard let value = try? String(contentsOf: fileURL, encoding: .utf8), !value.isEmpty else {
      return nil
    }
    try? FileManager.default.removeItem(at: fileURL)
    return value
  }
}
