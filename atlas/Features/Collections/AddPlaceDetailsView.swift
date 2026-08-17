import SwiftUI
import SwiftData

/// Screen 07 — Add Place. The fast-capture sheet.
///
/// `Vision.md` targets under ten seconds to save a place, so everything needed is
/// on one screen with no further navigation: name (already known), notes, category,
/// photo.
struct AddPlaceDetailsView: View {
  let place: PendingPlace
  let onSave: (String, String, [Data]) -> Void
  let onCancel: () -> Void

  @Query(sort: \Category.sortOrder) private var categories: [Category]
  @State private var notes = ""
  @State private var category = ""
  @State private var photoDatas: [Data] = []

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AtlasDivider()
        ScrollView {
          VStack(alignment: .leading, spacing: 22) {
            Text(place.name)
              .font(AtlasFont.sheetTitle)
              .foregroundStyle(AtlasColor.text)

            AtlasFormField(label: "Notes") {
              TextField(
                "Why does this place matter?",
                text: $notes,
                axis: .vertical
              )
              .font(AtlasFont.bodyLarge)
              .lineLimit(4...4)
              .atlasInputBackground()
            }

            AtlasFormField(label: "Category") {
              AtlasSegmentedControl(options: categories.map(\.name), selection: $category)
            }

            PlacePhotoPicker(photoDatas: $photoDatas)
          }
          .padding(AtlasSpacing.screenHorizontal)
        }
      }
      .background(AtlasColor.background)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: onCancel)
            .font(AtlasFont.body)
            .foregroundStyle(AtlasColor.textSecondary)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(notes, category, photoDatas)
          }
          .font(AtlasFont.action)
          .foregroundStyle(AtlasColor.accent)
        }
      }
      .onAppear {
        if category.isEmpty {
          category = categories.first?.name ?? "other"
        }
      }
    }
  }
}
