import SwiftUI

/// A labelled field from the design: a small caption above the control.
///
/// The design lays fields out flat on the page rather than in grouped, rounded
/// `Form` sections, which would contradict the square-cornered language.
struct AtlasFormField<Content: View>: View {
  let label: String
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(label)
        .font(AtlasFont.caption)
        .foregroundStyle(AtlasColor.text.opacity(0.7))
      content
    }
  }
}

extension View {
  /// The design's input chrome: surface fill, hairline border, square corners.
  func atlasInputBackground() -> some View {
    self
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(AtlasColor.surface)
      .overlay(Rectangle().strokeBorder(AtlasColor.divider, lineWidth: 1))
  }
}
