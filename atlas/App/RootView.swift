import SwiftUI

/// The app shell: three tabs from the design, with the splash held above them.
///
/// Each tab's root view owns its own `NavigationStack` rather than sharing one —
/// nesting stacks is what previously broke drill-down navigation.
private enum AppTab: Hashable {
  case library, map, search
}

struct RootView: View {
  @Environment(\.scenePhase) private var scenePhase
  @State private var showSplash = true
  @State private var selectedTab: AppTab = .library
  @State private var mapFocus = MapFocusRequest()
  @State private var pendingShare = PendingShareRequest()

  var body: some View {
    ZStack {
      TabView(selection: $selectedTab) {
        Tab("COLLECTIES", systemImage: "square.stack", value: .library) {
          LibraryView()
        }
        Tab("KAART", systemImage: "map", value: .map) {
          MapTabView()
        }
        Tab("ZOEKEN", systemImage: "magnifyingglass", value: .search) {
          SearchTabView()
        }
      }
      .tint(AtlasColor.accent)

      if showSplash {
        SplashView()
          .transition(.opacity)
          .zIndex(1)
      }
    }
    .environment(mapFocus)
    .environment(pendingShare)
    .onChange(of: mapFocus.place) { _, place in
      if place != nil { selectedTab = .map }
    }
    // The share extension can't switch back to Atlas itself — see
    // `ShareViewController`'s doc comment — so a pending share is picked up
    // here instead, on every foreground transition.
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { checkForPendingShare() }
    }
    .task {
      checkForPendingShare()
      try? await Task.sleep(for: .seconds(1.8))
      withAnimation(.easeOut(duration: 0.35)) {
        showSplash = false
      }
    }
  }

  private func checkForPendingShare() {
    guard let urlString = MapsShareInbox.takePending() else { return }
    pendingShare.urlString = urlString
    selectedTab = .search
  }
}
