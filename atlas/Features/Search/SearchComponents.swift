import SwiftUI

/// The design's search field: square, hairline-bordered, icon then text.
struct AtlasSearchField: View {
  @Binding var text: String
  var placeholder = "Search places"
  @FocusState.Binding var isFocused: Bool

  var body: some View {
    HStack(spacing: AtlasSpacing.s) {
      Image(systemName: "magnifyingglass")
        .font(AtlasFont.bodyLarge)
        .foregroundStyle(AtlasColor.textSecondary)
        .accessibilityHidden(true)

      TextField(placeholder, text: $text)
        .font(AtlasFont.bodyLarge)
        .foregroundStyle(AtlasColor.text)
        .focused($isFocused)
        .submitLabel(.search)
        .autocorrectionDisabled()

      if !text.isEmpty {
        Button {
          text = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(AtlasColor.neutral500)
        }
        .accessibilityLabel("Clear search")
      }
    }
    .padding(.horizontal, AtlasSpacing.m)
    .padding(.vertical, 9)
    .overlay(Rectangle().strokeBorder(AtlasColor.divider, lineWidth: 1))
  }
}

/// A single search result row. `trailing` carries the row's action, which differs
/// between the Search tab (Add) and the in-collection sheet (selection only).
///
/// Takes a plain title/subtitle rather than a `PlaceSearchResult` directly —
/// the Search tab's rows show `PlaceSearchCompleter` suggestions, which have no
/// coordinate (and so aren't a `PlaceSearchResult`) until the user picks one.
/// `title` is an `AttributedString` so callers can bold the substring that
/// matched the typed query.
struct PlaceResultRow<Trailing: View>: View {
  let title: AttributedString
  var subtitle: String = ""
  var isSelected = false
  @ViewBuilder var trailing: Trailing

  init(title: AttributedString, subtitle: String = "", isSelected: Bool = false, @ViewBuilder trailing: () -> Trailing) {
    self.title = title
    self.subtitle = subtitle
    self.isSelected = isSelected
    self.trailing = trailing()
  }

  init(result: PlaceSearchResult, isSelected: Bool = false, @ViewBuilder trailing: () -> Trailing) {
    self.init(title: AttributedString(result.name), subtitle: result.subtitle, isSelected: isSelected, trailing: trailing)
  }

  var body: some View {
    HStack(alignment: .center, spacing: AtlasSpacing.m) {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(AtlasFont.resultTitle)
          .foregroundStyle(isSelected ? AtlasColor.accent800 : AtlasColor.text)
          .multilineTextAlignment(.leading)

        if !subtitle.isEmpty {
          Text(subtitle)
            .font(AtlasFont.caption)
            .foregroundStyle(AtlasColor.textSecondary)
            .multilineTextAlignment(.leading)
        }
      }

      Spacer(minLength: 0)

      trailing
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, 14)
    .background(isSelected ? AtlasColor.accent100 : Color.clear)
    .contentShape(Rectangle())
  }
}

/// Pinned option above search results: resolve the device's current location and
/// feed it into the same result the user would get by typing an address.
struct CurrentLocationRow: View {
  var isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: AtlasSpacing.m) {
        Image(systemName: "location.fill")
          .foregroundStyle(AtlasColor.accent)
          .frame(width: 20)

        Text("Use Current Location")
          .font(AtlasFont.resultTitle)
          .foregroundStyle(AtlasColor.accent)

        Spacer(minLength: 0)

        if isLoading {
          ProgressView()
        }
      }
      .padding(.horizontal, AtlasSpacing.screenHorizontal)
      .padding(.vertical, 14)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(isLoading)
    .accessibilityLabel("Use current location")
  }
}

/// Pinned option above search results: read an Apple Maps or Google Maps share
/// link off the clipboard and resolve it into a result, the same way
/// `CurrentLocationRow` does for the device's own location.
struct PasteLocationRow: View {
  var isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: AtlasSpacing.m) {
        Image(systemName: "link")
          .foregroundStyle(AtlasColor.accent)
          .frame(width: 20)

        Text("Paste from Maps")
          .font(AtlasFont.resultTitle)
          .foregroundStyle(AtlasColor.accent)

        Spacer(minLength: 0)

        if isLoading {
          ProgressView()
        }
      }
      .padding(.horizontal, AtlasSpacing.screenHorizontal)
      .padding(.vertical, 14)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(isLoading)
    .accessibilityLabel("Paste location from Apple Maps or Google Maps")
  }
}

/// Centred placeholder used for the empty and no-results states.
struct SearchPlaceholder: View {
  let systemImage: String
  let message: String

  var body: some View {
    VStack(spacing: AtlasSpacing.m) {
      Image(systemName: systemImage)
        .font(.system(size: 40))
        .foregroundStyle(AtlasColor.neutral400)
      Text(message)
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
