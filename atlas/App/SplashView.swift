import SwiftUI

/// Screen 01 — Splash.
///
/// `LaunchScreen.storyboard` (the system-rendered screen shown before this view ever
/// runs) is solid blue with no mark or wordmark — it can't load the bundled display
/// font, so any text or logo placed there would either flash in the wrong font or
/// pop in a beat before this view takes over. Fading everything in here, against a
/// background that already matches the launch screen, makes the handoff invisible
/// instead.
struct SplashView: View {
  @State private var isVisible = false

  var body: some View {
    ZStack {
      AtlasColor.iconBlue

      VStack(spacing: 22) {
        AtlasMark()
          .frame(width: 120, height: 120)

        VStack(spacing: 8) {
          Text("Goeieplek")
            .font(AtlasFont.splash)
          Text("Remember places that matter")
            .font(AtlasFont.bodyLarge)
            .opacity(0.92)
        }
        .foregroundStyle(.white)
      }
      .opacity(isVisible ? 1 : 0)
    }
    .ignoresSafeArea()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Goeieplek — remember places that matter")
    .onAppear {
      withAnimation(.easeOut(duration: 0.3)) {
        isVisible = true
      }
    }
  }
}
