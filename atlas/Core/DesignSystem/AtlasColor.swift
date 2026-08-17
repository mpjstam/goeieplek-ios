import SwiftUI

/// The Atlas palette, ported from the Claude design project "Atlas iOS app design".
///
/// Light values are taken verbatim from the design. The design is light-only, but
/// Dark Mode is mandatory (`Architecture.md`), so dark values mirror each tonal ramp
/// — step *N* in dark resolves to step *1000 − N* of the light ramp. That keeps the
/// relationships between steps intact (a "tint background" stays a tint background)
/// without maintaining a second hand-tuned palette.
enum AtlasColor {

  // MARK: - Core

  static let background = Color.dynamic(light: 0xF3F2F2, dark: 0x141312)
  static let surface = Color.dynamic(light: 0xEAE9E9, dark: 0x1F1E1D)
  static let text = Color.dynamic(light: 0x201E1D, dark: 0xF3F2F2)
  static let accent = Color.dynamic(light: 0x3552E0, dark: 0x5B76FA)

  /// Brand blue behind the app icon and splash. Fixed in both appearances —
  /// it is part of the mark, not the theme.
  static let iconBlue = Color(hex: 0x009DFF)

  /// Rules in the design are 2pt at 40% of the text colour.
  static let divider = text.opacity(0.4)

  // MARK: - Accent ramp

  static let accent100 = Color.dynamic(light: 0xEEF1FF, dark: 0x131D52)
  static let accent200 = Color.dynamic(light: 0xDBE2FF, dark: 0x1B2A7A)
  static let accent300 = Color.dynamic(light: 0xB7C5FF, dark: 0x2438AD)
  static let accent400 = Color.dynamic(light: 0x8BA0FF, dark: 0x3552E0)
  static let accent500 = Color.dynamic(light: 0x5B76FA, dark: 0x5B76FA)
  static let accent600 = Color.dynamic(light: 0x3552E0, dark: 0x8BA0FF)
  static let accent700 = Color.dynamic(light: 0x2438AD, dark: 0xB7C5FF)
  static let accent800 = Color.dynamic(light: 0x1B2A7A, dark: 0xDBE2FF)
  static let accent900 = Color.dynamic(light: 0x131D52, dark: 0xEEF1FF)

  // MARK: - Neutral ramp

  static let neutral100 = Color.dynamic(light: 0xF8F4F4, dark: 0x2D2B2B)
  static let neutral200 = Color.dynamic(light: 0xEAE7E7, dark: 0x444141)
  static let neutral300 = Color.dynamic(light: 0xD7D3D3, dark: 0x605D5D)
  static let neutral400 = Color.dynamic(light: 0xBAB6B6, dark: 0x7D7979)
  static let neutral500 = Color.dynamic(light: 0x9B9797, dark: 0x9B9797)
  static let neutral600 = Color.dynamic(light: 0x7D7979, dark: 0xBAB6B6)
  static let neutral700 = Color.dynamic(light: 0x605D5D, dark: 0xD7D3D3)
  static let neutral800 = Color.dynamic(light: 0x444141, dark: 0xEAE7E7)
  static let neutral900 = Color.dynamic(light: 0x2D2B2B, dark: 0xF8F4F4)

  // MARK: - Semantic aliases

  /// Secondary body copy — descriptions, subtitles, notes.
  static let textSecondary = neutral700

  /// Micro-labels such as LATITUDE / SAVED / CATEGORY.
  static let textTertiary = neutral600

  /// Unselected tab items.
  static let textInactive = neutral500

  // MARK: - Category tag hues

  /// Background/foreground tint pairs for category tags, cycling through the
  /// six rainbow-band hues from the app icon and splash mark (red, orange,
  /// yellow, green, blue, purple). Light values are taken from the design;
  /// dark values mirror them the same way the accent ramp does.
  private static let categoryTagRamp: [(background: Color, foreground: Color)] = [
    (Color.dynamic(light: 0xFFE0D9, dark: 0x7C1405), Color.dynamic(light: 0xAE1800, dark: 0xFFC4B8)), // red
    (Color.dynamic(light: 0xFFE3C9, dark: 0x7F3006), Color.dynamic(light: 0xB34305, dark: 0xFFC78E)), // orange
    (Color.dynamic(light: 0xFFEDBF, dark: 0x4D3800), Color.dynamic(light: 0x8A5A00, dark: 0xFFE085)), // yellow
    (Color.dynamic(light: 0xD3F5E6, dark: 0x0B3A26), Color.dynamic(light: 0x146A45, dark: 0x9CE8C4)), // green
    (Color.dynamic(light: 0xDBE6FF, dark: 0x152B6B), Color.dynamic(light: 0x1B3AA8, dark: 0xB8CBFF)), // blue
    (Color.dynamic(light: 0xEDE4FF, dark: 0x3B1878), Color.dynamic(light: 0x5B21B6, dark: 0xD9C7FF)), // purple
  ]

  /// Picks a hue for a category tag, keyed by name (not position) so a given
  /// category always gets the same colour everywhere it's shown. Uses a plain
  /// checksum rather than `String.hashValue`, which is randomised per process
  /// launch and would make the colour change every time the app restarts.
  static func categoryTagColors(for category: String) -> (background: Color, foreground: Color) {
    let checksum = category.lowercased().unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return categoryTagRamp[checksum % categoryTagRamp.count]
  }
}
