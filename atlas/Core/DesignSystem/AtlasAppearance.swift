import SwiftUI
import UIKit

/// Applies the Atlas look to UIKit-backed chrome that SwiftUI does not style directly.
///
/// The tab bar stays a real `UITabBar` — `Vision.md` says not to reinvent standard
/// controls — so its typography and colours are set through `UITabBarAppearance`
/// rather than by hand-rolling a custom bar.
enum AtlasAppearance {

  static func apply() {
    configureTabBar()
  }

  private static func configureTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(AtlasColor.background)

    // The design separates the tab bar with the same 2pt rule used elsewhere.
    appearance.shadowColor = UIColor(AtlasColor.divider)

    let label = tabLabelFont()
    for item in [appearance.stackedLayoutAppearance,
                 appearance.inlineLayoutAppearance,
                 appearance.compactInlineLayoutAppearance] {
      item.normal.iconColor = UIColor(AtlasColor.textInactive)
      item.normal.titleTextAttributes = [
        .font: label,
        .foregroundColor: UIColor(AtlasColor.textInactive),
        .kern: 0.4
      ]
      item.selected.iconColor = UIColor(AtlasColor.accent)
      item.selected.titleTextAttributes = [
        .font: label,
        .foregroundColor: UIColor(AtlasColor.accent),
        .kern: 0.4
      ]
    }

    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }

  /// 10pt display face, scaled for Dynamic Type, falling back to a system
  /// semibold if the bundled face is unavailable.
  private static func tabLabelFont() -> UIFont {
    let base = UIFont(name: "Sora-ExtraBold", size: 10)
      ?? .systemFont(ofSize: 10, weight: .heavy)
    return UIFontMetrics(forTextStyle: .caption2).scaledFont(for: base)
  }
}
