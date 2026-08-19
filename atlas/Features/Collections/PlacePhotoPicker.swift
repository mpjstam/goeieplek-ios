import SwiftUI
import PhotosUI
import UIKit

/// Photo slots from the design, extended to a horizontal row of up to
/// `Photo.maxPerPlace` 100pt thumbnails plus an add tile, each removable
/// individually.
///
/// Laid out as a plain view (not a `Form` `Section`) so it can sit in the flat
/// field stack used by both the add and edit sheets.
struct PlacePhotoPicker: View {
  @Binding var photoDatas: [Data]
  @State private var selectedItems: [PhotosPickerItem] = []

  private var remainingSlots: Int {
    Photo.maxPerPlace - photoDatas.count
  }

  var body: some View {
    AtlasFormField(label: label) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: AtlasSpacing.s) {
          ForEach(Array(photoDatas.enumerated()), id: \.offset) { index, data in
            thumbnail(data, index: index)
          }

          if remainingSlots > 0 {
            PhotosPicker(
              selection: $selectedItems,
              maxSelectionCount: remainingSlots,
              matching: .images
            ) {
              addTile
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voeg een foto toe")
          }
        }
      }
    }
    .onChange(of: selectedItems) { _, newItems in
      guard !newItems.isEmpty else { return }
      Task {
        var loaded: [Data] = []
        for item in newItems {
          if let data = try? await item.loadTransferable(type: Data.self) {
            loaded.append(data)
          }
        }
        photoDatas.append(contentsOf: loaded.prefix(remainingSlots))
        selectedItems = []
      }
    }
  }

  private var label: String {
    photoDatas.isEmpty ? "Foto" : "Foto's (\(photoDatas.count)/\(Photo.maxPerPlace))"
  }

  private func thumbnail(_ data: Data, index: Int) -> some View {
    ZStack(alignment: .topTrailing) {
      if let image = UIImage(data: data) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: 100, height: 100)
          .clipped()
      } else {
        AtlasColor.surface.frame(width: 100, height: 100)
      }

      Button {
        photoDatas.remove(at: index)
      } label: {
        Image(systemName: "xmark.circle.fill")
          .symbolRenderingMode(.palette)
          .foregroundStyle(.white, .black.opacity(0.6))
          .padding(6)
      }
      .accessibilityLabel("Verwijder foto \(index + 1)")
    }
    .overlay(Rectangle().strokeBorder(AtlasColor.divider, lineWidth: 1))
  }

  private var addTile: some View {
    ZStack {
      AtlasColor.surface
      VStack(spacing: 4) {
        Image(systemName: "plus")
        Text("Voeg toe").font(AtlasFont.caption)
      }
      .foregroundStyle(AtlasColor.textSecondary)
    }
    .frame(width: 100, height: 100)
    .overlay(Rectangle().strokeBorder(AtlasColor.divider, lineWidth: 1))
  }
}
