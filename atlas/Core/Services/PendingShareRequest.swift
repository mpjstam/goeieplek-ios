import Observation

/// Cross-tab signal: set `urlString` to hand a shared maps link (picked up
/// from `MapsShareInbox`) to the Search tab, which resolves and previews it
/// through the same flow as a pasted link. Shared via the environment from
/// `RootView`, mirroring `MapFocusRequest`.
@Observable
final class PendingShareRequest {
  var urlString: String?
}
