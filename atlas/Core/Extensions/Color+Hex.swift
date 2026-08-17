import SwiftUI
import UIKit

extension Color {
  /// Creates a colour from a 24-bit RGB literal, e.g. `Color(hex: 0x3552E0)`.
  init(hex: UInt32) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: 1
    )
  }

  /// Creates a colour that resolves differently in light and dark appearance.
  ///
  /// SwiftUI has no native dynamic-colour API, so this bridges through `UIColor`.
  /// The alternative — one asset-catalog colourset per token — would scatter the
  /// palette across ~23 JSON folders and make retuning it much harder to review.
  static func dynamic(light: UInt32, dark: UInt32) -> Color {
    Color(UIColor { traits in
      UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
    })
  }
}
