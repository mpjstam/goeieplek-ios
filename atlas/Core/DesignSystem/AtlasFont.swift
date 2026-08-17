import SwiftUI
import CoreText
import OSLog

/// The Atlas type scale.
///
/// Sizes are taken from the design. Every face is declared with `relativeTo:` so
/// Dynamic Type still scales it — the design specifies fixed pixel sizes, but
/// `Architecture.md` makes Dynamic Type mandatory, and `relativeTo:` satisfies both
/// by treating the design size as the value at the default text size.
///
/// Headings use Sora ExtraBold (the design's display face). Body copy stays on the
/// system font: at 11–13pt SF is more legible than a bundled grotesque, it is what
/// "Apple native" in `Vision.md` asks for, and it keeps the bundle small.
enum AtlasFont {

  private static let headingFace = "Sora-ExtraBold"
  private static let headingResource = "Sora-ExtraBold"

  // MARK: - Registration

  /// Registers the bundled display face for the current process.
  ///
  /// Registration is done in code rather than via `UIAppFonts` because this target
  /// generates its `Info.plist` from build settings, and Xcode does not expose
  /// `UIAppFonts` as an `INFOPLIST_KEY_*` (verified: the key is silently dropped).
  ///
  /// If this fails, `Font.custom` falls back to the system face, so the app still
  /// renders — it just loses the display typeface.
  static func register() {
    guard let url = Bundle.main.url(forResource: headingResource, withExtension: "ttf") else {
      AtlasLog.designSystem.error("\(headingResource, privacy: .public).ttf missing from bundle; using system font.")
      return
    }

    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
      let description = error?.takeRetainedValue().localizedDescription ?? "unknown error"
      AtlasLog.designSystem.error("Failed to register display font: \(description, privacy: .public)")
    }
  }

  // MARK: - Display faces (Sora ExtraBold)

  /// 40pt — splash wordmark.
  static let splash = heading(40, relativeTo: .largeTitle)
  /// 30pt — "Atlas" in the Library header.
  static let wordmark = heading(30, relativeTo: .largeTitle)
  /// 25pt — screen titles (Map, Search, Categories, collection name).
  static let screenTitle = heading(25, relativeTo: .title)
  /// 23pt — place name on the place detail screen.
  static let placeTitle = heading(23, relativeTo: .title2)
  /// 22pt — place name on the add-place sheet.
  static let sheetTitle = heading(22, relativeTo: .title2)
  /// 18pt — collection name in the Library list.
  static let collectionRow = heading(18, relativeTo: .headline)
  /// 16pt — place and category row titles.
  static let rowTitle = heading(16, relativeTo: .headline)
  /// 15pt — search result titles.
  static let resultTitle = heading(15, relativeTo: .subheadline)
  /// 14pt — action labels such as Save.
  static let action = heading(14, relativeTo: .subheadline)
  /// 11pt — inline row actions such as RENAME.
  static let rowAction = heading(11, relativeTo: .caption)
  /// 10pt — tab bar labels.
  static let tabLabel = heading(10, relativeTo: .caption2)

  // MARK: - Body faces (system)
  //
  // Declared as text styles rather than `.system(size:)`, because a fixed point
  // size does not respond to Dynamic Type at all. Conveniently the design's body
  // sizes match the default metrics of the built-in styles exactly, so this costs
  // no fidelity: subheadline 15, footnote 13, caption 12, caption2 11.

  /// 15pt — splash subtitle, search field text, form inputs.
  static let bodyLarge = Font.subheadline
  /// 13pt — descriptions and notes.
  static let body = Font.footnote
  /// 12pt — secondary captions and field labels.
  static let caption = Font.caption
  /// 11pt — uppercase micro-labels (LATITUDE, SAVED, CATEGORY).
  static let microLabel = Font.caption2
  /// Monospaced coordinates. Uses the 15pt style — nearest scaling match to the
  /// design's 14pt, which has no built-in equivalent.
  static let mono = Font.system(.subheadline, design: .monospaced)

  // MARK: - Helpers

  private static func heading(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
    .custom(headingFace, size: size, relativeTo: style)
  }
}

// MARK: - Text treatments

extension View {
  /// Uppercase micro-label: 11pt, wide tracking, tertiary colour.
  /// Used for LATITUDE / LONGITUDE / CATEGORY / SAVED.
  func atlasMicroLabel() -> some View {
    self.font(AtlasFont.microLabel)
      .textCase(.uppercase)
      .tracking(0.88) // 0.08em at 11pt
      .foregroundStyle(AtlasColor.textTertiary)
  }

  /// Tab bar label: 10pt display face, uppercase, slight tracking.
  func atlasTabLabel() -> some View {
    self.font(AtlasFont.tabLabel)
      .textCase(.uppercase)
      .tracking(0.4) // 0.04em at 10pt
  }
}
