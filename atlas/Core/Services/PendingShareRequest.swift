import Observation

/// Cross-tab signal: append to `urlStrings` to hand shared maps links (picked
/// up from `MapsShareInbox`) to the Search tab, which resolves and previews
/// each one through the same flow as a pasted link. Plural because sharing
/// several places in a row before ever opening Atlas queues all of them.
/// Shared via the environment from `RootView`, mirroring `MapFocusRequest`.
@Observable
final class PendingShareRequest {
  var urlStrings: [String] = []
}
