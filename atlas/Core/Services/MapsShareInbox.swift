import Foundation

/// Reads back whatever `AtlasShare`'s `ShareViewController` dropped in the App
/// Group container — one or more Apple Maps or Google Maps links, one file per
/// share so sharing several places in a row before ever opening Atlas queues
/// all of them instead of each one overwriting the last. The extension can't
/// reliably switch back to Atlas itself (see its doc comment), so this is
/// polled by `RootView` on every activation instead of waiting on a deep link
/// that might not arrive.
enum MapsShareInbox {
  private static let appGroupID = "group.studiostam.atlas"
  private static let pendingDirectoryName = "PendingMapsShares"

  /// Returns and clears every pending share, oldest first — the filename's
  /// zero-padded sequence-number prefix (see `ShareViewController.persist(_:)`)
  /// is what makes that ordering recoverable without a separate index file.
  /// An empty array
  /// covers "nothing was shared," "the directory doesn't exist yet," and "the
  /// App Group container isn't reachable" alike — either way there's nothing
  /// for the caller to act on.
  static func takeAllPending() -> [String] {
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      return []
    }
    let directoryURL = containerURL.appendingPathComponent(pendingDirectoryName, isDirectory: true)
    guard let fileURLs = try? FileManager.default.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil
    ) else {
      return []
    }
    return fileURLs
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
      .compactMap { fileURL in
        guard let value = try? String(contentsOf: fileURL, encoding: .utf8), !value.isEmpty else {
          // Leave the file in place on a failed/empty read so the next poll
          // retries it, instead of deleting a share we never actually read.
          return nil
        }
        try? FileManager.default.removeItem(at: fileURL)
        return value
      }
  }
}
