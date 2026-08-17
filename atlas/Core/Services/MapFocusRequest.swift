import Observation

/// Cross-tab signal: set `place` to ask the Map tab to center on it.
/// Shared via the environment from `RootView` so any pushed screen (Library
/// or Map's own stack) can request a focus without owning tab-selection state.
@Observable
final class MapFocusRequest {
  var place: Place?
}
