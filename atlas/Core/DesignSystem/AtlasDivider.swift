import SwiftUI

/// The design's 2pt rule.
///
/// SwiftUI's `Divider` renders a hairline that cannot be thickened reliably, so
/// this draws the rule directly.
struct AtlasDivider: View {
  var body: some View {
    Rectangle()
      .fill(AtlasColor.divider)
      .frame(height: AtlasSpacing.dividerWidth)
      .accessibilityHidden(true)
  }
}
