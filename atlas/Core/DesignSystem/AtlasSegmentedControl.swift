import SwiftUI

/// The design's segmented control: square, hairline-bordered, selected segment
/// filled with the accent colour.
///
/// The design mocks three fixed options, but categories are user-managed and can
/// grow well past that, so the row scrolls horizontally once it overflows. That
/// preserves the design's appearance without clipping or shrinking labels below
/// a legible size.
struct AtlasSegmentedControl: View {
  let options: [String]
  @Binding var selection: String

  /// Title-cases the raw stored value for display (categories are stored lowercase).
  private func label(_ option: String) -> String {
    option.capitalized
  }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 0) {
        ForEach(Array(options.enumerated()), id: \.element) { index, option in
          if index > 0 {
            Rectangle()
              .fill(AtlasColor.divider)
              .frame(width: 1)
              .accessibilityHidden(true)
          }
          segment(option)
        }
      }
    }
    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    .overlay(Rectangle().strokeBorder(AtlasColor.divider, lineWidth: 1))
    .accessibilityElement(children: .contain)
  }

  private func segment(_ option: String) -> some View {
    let isSelected = option == selection
    return Button {
      selection = option
    } label: {
      Text(label(option))
        .font(AtlasFont.body)
        .foregroundStyle(isSelected ? AtlasColor.background : AtlasColor.text)
        .padding(.horizontal, AtlasSpacing.m)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(isSelected ? AtlasColor.accent : Color.clear)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label(option))
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
  }
}
