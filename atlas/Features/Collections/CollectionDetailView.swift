import SwiftUI
import UIKit
import OSLog

/// Screen 03 — Collection. The places inside one collection.
///
/// The native navigation bar is kept (with an empty title) so the back button and
/// the interactive pop gesture keep working; the design's large title is drawn in
/// content beneath it. The tab bar hides on push, matching the design.
struct CollectionDetailView: View {
  let collection: Collection
  let repository: CollectionsRepository
  @Binding var navigationPath: [NavigationDestination]

  @State private var showingSearch = false
  @State private var pendingPlace: PendingPlace?
  @State private var showingEdit = false
  @State private var editName = ""
  @State private var editNotes = ""

  var body: some View {
    VStack(spacing: 0) {
      title
      AtlasDivider()
      content
    }
    .background(AtlasColor.background)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Menu {
          ShareLink("Deel als tekst", item: shareText)
          ShareLink(
            "Deel als Goeieplek-bestand",
            item: SharedCollection(collection),
            preview: SharePreview(collection.name)
          )
        } label: {
          Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Deel collectie")

        Button { showingEdit = true } label: {
          Image(systemName: "pencil")
        }
        .accessibilityLabel("Collectie hernoemen")

        Button { showingSearch = true } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Plek toevoegen")
      }
    }
    .tint(AtlasColor.accent)
    .sheet(isPresented: $showingSearch) {
      SearchPlacesView { name, lat, lng in
        showingSearch = false
        pendingPlace = PendingPlace(name: name, latitude: lat, longitude: lng)
      }
    }
    .sheet(item: $pendingPlace) { place in
      AddPlaceDetailsView(
        place: place,
        onSave: { notes, category, photoDatas in
          save(place, notes: notes, category: category, photoDatas: photoDatas)
        },
        onCancel: { pendingPlace = nil }
      )
    }
    .sheet(isPresented: $showingEdit) { editSheet }
  }

  private var title: some View {
    Text(collection.name)
      .font(AtlasFont.screenTitle)
      .foregroundStyle(AtlasColor.text)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, AtlasSpacing.screenHorizontal)
      .padding(.bottom, AtlasSpacing.l)
  }

  @ViewBuilder
  private var content: some View {
    if collection.places.isEmpty {
      emptyState
    } else {
      placesList
    }
  }

  private var placesList: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(collection.places) { place in
          Button {
            navigationPath.append(.place(place))
          } label: {
            placeRow(place)
          }
          .buttonStyle(.plain)
          AtlasDivider()
        }
      }
    }
  }

  private func placeRow(_ place: Place) -> some View {
    HStack(alignment: .top, spacing: AtlasSpacing.m) {
      if let firstPhoto = place.sortedPhotos.first, let image = UIImage(data: firstPhoto.data) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: AtlasSpacing.thumbnail, height: AtlasSpacing.thumbnail)
          .clipped()
          .accessibilityHidden(true)
      }

      VStack(alignment: .leading, spacing: AtlasSpacing.xs) {
        Text(place.name)
          .font(AtlasFont.rowTitle)
          .foregroundStyle(AtlasColor.text)

        if !place.notes.isEmpty {
          Text(place.notes)
            .font(AtlasFont.caption)
            .foregroundStyle(AtlasColor.textSecondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
        }

        AtlasTag(category: place.category)
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, AtlasSpacing.l)
    .contentShape(Rectangle())
  }

  private var emptyState: some View {
    VStack(spacing: AtlasSpacing.m) {
      Image(systemName: "mappin")
        .font(.system(size: 40))
        .foregroundStyle(AtlasColor.neutral400)
      Text("Nog geen plekken")
        .font(AtlasFont.rowTitle)
        .foregroundStyle(AtlasColor.text)
      Text("Zoek of voeg je eerste plek aan deze collectie toe")
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, AtlasSpacing.xl)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - Actions

  private func save(_ place: PendingPlace, notes: String, category: String, photoDatas: [Data]) {
    do {
      _ = try repository.addPlace(
        to: collection,
        name: place.name,
        notes: notes,
        latitude: place.latitude,
        longitude: place.longitude,
        category: category,
        photoDatas: photoDatas
      )
    } catch {
      AtlasLog.library.error("Failed to add place: \(error.localizedDescription, privacy: .public)")
    }
    pendingPlace = nil
  }

  private var editSheet: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AtlasDivider()
        ScrollView {
          VStack(alignment: .leading, spacing: 22) {
            AtlasFormField(label: "Naam") {
              TextField("Naam van de collectie", text: $editName)
                .font(AtlasFont.bodyLarge)
                .atlasInputBackground()
            }

            AtlasFormField(label: "Notities") {
              TextField(
                "Wat verbindt deze plekken?",
                text: $editNotes,
                axis: .vertical
              )
              .font(AtlasFont.bodyLarge)
              .lineLimit(4...4)
              .atlasInputBackground()
            }
          }
          .padding(AtlasSpacing.screenHorizontal)
        }
      }
      .background(AtlasColor.background)
      .navigationTitle("Collectie bewerken")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuleer") { showingEdit = false }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Bewaar", action: saveEdits)
            .disabled(editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
      // Seeded here rather than where the sheet is presented — doing it there
      // races the sheet's first layout and can leave Save disabled against
      // stale state (see the same note on PlaceDetailView's edit sheet).
      .onAppear {
        editName = collection.name
        editNotes = collection.notes
      }
    }
  }

  private func saveEdits() {
    do {
      try repository.updateCollection(collection, name: editName, notes: editNotes)
      showingEdit = false
    } catch {
      AtlasLog.library.error("Failed to update collection: \(error.localizedDescription, privacy: .public)")
    }
  }

  private var shareText: String {
    var lines = ["📍 \(collection.name)"]
    if !collection.notes.isEmpty {
      lines.append(collection.notes)
    }

    if collection.places.isEmpty {
      lines.append("\nNog geen plekken.")
    } else {
      for place in collection.places {
        lines.append("")
        lines.append("• \(place.name) (\(place.category.capitalized))")
        if !place.notes.isEmpty {
          lines.append(place.notes)
        }
        let query = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place.name
        lines.append("https://maps.apple.com/?ll=\(place.latitude),\(place.longitude)&q=\(query)")
      }
    }

    lines.append("\nGedeeld vanuit Goeieplek")
    return lines.joined(separator: "\n")
  }
}
