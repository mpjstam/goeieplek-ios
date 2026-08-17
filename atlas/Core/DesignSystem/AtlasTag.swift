import SwiftUI

/// Small pill label used for categories and counts.
///
/// Two variants exist in the design: a filled tint (`.accent`, used for a place's
/// category) and an outline (`.outline`, used for "8 places" and map filters).
struct AtlasTag: View {
  enum Style {
    case accent
    case outline
    case rainbow(background: Color, foreground: Color)
  }

  let text: String
  var style: Style = .accent

  /// A category tag, tinted with one of the six rainbow hues keyed by name —
  /// see `AtlasColor.categoryTagColors(for:)`.
  init(category: String) {
    let colors = AtlasColor.categoryTagColors(for: category)
    self.text = category.capitalized
    self.style = .rainbow(background: colors.background, foreground: colors.foreground)
  }

  init(text: String, style: Style = .accent) {
    self.text = text
    self.style = style
  }

  var body: some View {
    Text(text)
      .font(AtlasFont.microLabel)
      .tracking(0.22) // 0.02em at 11pt
      .foregroundStyle(foreground)
      .padding(.horizontal, 10)
      .padding(.vertical, 3)
      .background(background)
      .overlay(border)
  }

  private var foreground: Color {
    switch style {
    case .accent: AtlasColor.accent800
    case .outline: AtlasColor.accent
    case .rainbow(_, let foreground): foreground
    }
  }

  @ViewBuilder
  private var background: some View {
    switch style {
    case .accent: AtlasColor.accent100
    case .outline: Color.clear
    case .rainbow(let background, _): background
    }
  }

  @ViewBuilder
  private var border: some View {
    switch style {
    case .accent, .rainbow: EmptyView()
    case .outline: Rectangle().strokeBorder(AtlasColor.accent, lineWidth: 1)
    }
  }
}
