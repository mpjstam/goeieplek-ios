import SwiftUI

/// The "Goeieplek" logotype — a custom display treatment (white letterforms, blue
/// outline, soft blue glow) exported directly from the design as `Wordmark.png`
/// rather than hand-drawn: the glow in particular doesn't translate to a crisp
/// vector redraw, and this is the exact asset the design produced.
struct Wordmark: View {
  var body: some View {
    Image("Wordmark")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .accessibilityHidden(true)
      .accessibilityAddTraits(.isHeader)
  }
}
