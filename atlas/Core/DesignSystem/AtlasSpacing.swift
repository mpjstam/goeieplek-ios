import CoreGraphics

/// Spacing and geometry constants from the design.
enum AtlasSpacing {
  static let xs: CGFloat = 4
  static let s: CGFloat = 8
  static let m: CGFloat = 12
  static let l: CGFloat = 16
  static let xl: CGFloat = 24
  static let xxl: CGFloat = 32

  /// Horizontal page inset used by every screen in the design.
  static let screenHorizontal: CGFloat = 20

  /// Vertical inset for list rows.
  static let rowVertical: CGFloat = 16

  /// Every corner in the design is square (`--radius-*: 0px`).
  static let radius: CGFloat = 0

  /// Rules are 2pt, not hairlines — a defining trait of the design.
  static let dividerWidth: CGFloat = 2

  /// Thumbnail edge on collection place rows.
  static let thumbnail: CGFloat = 52
}
