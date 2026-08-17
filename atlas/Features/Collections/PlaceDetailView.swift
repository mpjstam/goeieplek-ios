import SwiftUI
import SwiftData
import MapKit
import UIKit
import OSLog

/// Screen 04 — Place. One saved place.
///
/// Content order follows the design: photo, name, notes, coordinate band, map,
/// category, saved date.
struct PlaceDetailView: View {
  let place: Place
  let repository: CollectionsRepository

  @Query(sort: \Category.sortOrder) private var categories: [Category]
  @Query(sort: \Collection.createdAt, order: .reverse) private var collections: [Collection]
  @Environment(\.dismiss) private var dismiss
  @Environment(MapFocusRequest.self) private var mapFocus

  @State private var position: MapCameraPosition = .automatic
  @State private var showingEdit = false
  @State private var showingDeleteConfirm = false
  @State private var editName = ""
  @State private var editNotes = ""
  @State private var editCategory = ""
  @State private var editPhotoDatas: [Data] = []
  @State private var currentPhotoID: String?

  private var otherCollections: [Collection] {
    collections.filter { $0.id != place.collection?.id }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        photo
        heading
        coordinateBand
        map
        categoryRow
        savedRow
      }
      .padding(.horizontal, AtlasSpacing.screenHorizontal)
      .padding(.bottom, AtlasSpacing.xxl)
    }
    .background(AtlasColor.background)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button { showingEdit = true } label: {
          Image(systemName: "pencil")
        }
        .accessibilityLabel("Edit place")

        Menu {
          ForEach(otherCollections) { collection in
            Button(collection.name) { move(to: collection) }
          }
        } label: {
          Image(systemName: "folder")
        }
        .disabled(otherCollections.isEmpty)
        .accessibilityLabel("Move to another collection")

        Button { showingDeleteConfirm = true } label: {
          Image(systemName: "trash")
        }
        .tint(.red)
        .accessibilityLabel("Delete place")
      }
    }
    .tint(AtlasColor.accent)
    .confirmationDialog("Delete Place", isPresented: $showingDeleteConfirm) {
      Button("Delete", role: .destructive, action: deletePlace)
    } message: {
      Text("Are you sure you want to delete this place? This action cannot be undone.")
    }
    .sheet(isPresented: $showingEdit) { editSheet }
    .onAppear {
      position = .region(
        MKCoordinateRegion(
          center: place.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
      )
    }
  }

  // MARK: - Sections

  @ViewBuilder
  private var photo: some View {
    let photos = place.sortedPhotos
    if !photos.isEmpty {
      ZStack(alignment: .bottomTrailing) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: AtlasSpacing.s) {
            ForEach(photos, id: \.id) { photo in
              if let image = UIImage(data: photo.data) {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFill()
                  // 9/10 width, not the full container: leaves the next photo
                  // peeking at the edge as a hint that this scrolls.
                  .containerRelativeFrame(.horizontal, count: 10, span: 9, spacing: AtlasSpacing.s)
                  .frame(height: 190)
                  .clipped()
              }
            }
          }
          .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentPhotoID)
        .frame(height: 190)
        .accessibilityLabel(photos.count == 1 ? "Photo of \(place.name)" : "\(photos.count) photos of \(place.name)")

        if photos.count > 1 {
          AtlasTag(text: "\(currentPhotoNumber(in: photos)) / \(photos.count)")
            .padding(AtlasSpacing.s)
            .accessibilityHidden(true)
        }
      }
    }
  }

  private func currentPhotoNumber(in photos: [Photo]) -> Int {
    (photos.firstIndex { $0.id == currentPhotoID } ?? 0) + 1
  }

  private var heading: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(place.name)
        .font(AtlasFont.placeTitle)
        .foregroundStyle(AtlasColor.text)

      if !place.notes.isEmpty {
        Text(place.notes)
          .font(AtlasFont.body)
          .foregroundStyle(AtlasColor.textSecondary)
          .lineSpacing(3)
          .multilineTextAlignment(.leading)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.top, 18)
  }

  private var coordinateBand: some View {
    VStack(spacing: 0) {
      AtlasDivider()
      HStack(spacing: 0) {
        coordinate("Latitude", value: place.latitude)
        Rectangle()
          .fill(AtlasColor.divider)
          .frame(width: AtlasSpacing.dividerWidth)
          .accessibilityHidden(true)
        coordinate("Longitude", value: place.longitude)
          .padding(.leading, AtlasSpacing.l)
      }
      AtlasDivider()
    }
    .padding(.top, AtlasSpacing.xl)
  }

  private func coordinate(_ label: String, value: Double) -> some View {
    VStack(alignment: .leading, spacing: AtlasSpacing.xs) {
      Text(label).atlasMicroLabel()
      Text(String(format: "%.4f", value))
        .font(AtlasFont.mono)
        .foregroundStyle(AtlasColor.text)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, AtlasSpacing.m)
    .accessibilityElement(children: .combine)
  }

  private var map: some View {
    ZStack {
      Map(position: $position, interactionModes: []) {
        Marker(place.name, coordinate: place.coordinate)
      }
      .mapStyle(.standard)
      .allowsHitTesting(false)

      // A transparent tap-catcher on top: MapKit's own UIKit gesture
      // recognizers otherwise swallow touches before a Button around the
      // Map would see them, even with interactionModes empty.
      Color.clear
        .contentShape(Rectangle())
        .onTapGesture {
          mapFocus.place = place
        }
    }
    .frame(height: 170)
    .padding(.top, AtlasSpacing.xl)
    .accessibilityLabel("Show \(place.name) on the map")
    .accessibilityAddTraits(.isButton)
  }

  private var categoryRow: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Category").atlasMicroLabel()
        Spacer()
        AtlasTag(category: place.category)
      }
      .padding(.bottom, AtlasSpacing.s)
      AtlasDivider()
    }
    .padding(.top, AtlasSpacing.xl)
    .accessibilityElement(children: .combine)
  }

  private var savedRow: some View {
    HStack {
      Text("Saved").atlasMicroLabel()
      Spacer()
      Text(place.createdAt.formatted(date: .abbreviated, time: .omitted))
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.text)
    }
    .padding(.top, 14)
    .accessibilityElement(children: .combine)
  }

  // MARK: - Editing

  private var editSheet: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AtlasDivider()
        ScrollView {
          VStack(alignment: .leading, spacing: 22) {
            AtlasFormField(label: "Name") {
              TextField("Place name", text: $editName)
                .font(AtlasFont.bodyLarge)
                .atlasInputBackground()
            }

            AtlasFormField(label: "Notes") {
              TextField(
                "Why does this place matter?",
                text: $editNotes,
                axis: .vertical
              )
              .font(AtlasFont.bodyLarge)
              .lineLimit(4...4)
              .atlasInputBackground()
            }

            AtlasFormField(label: "Category") {
              AtlasSegmentedControl(options: categories.map(\.name), selection: $editCategory)
            }

            PlacePhotoPicker(photoDatas: $editPhotoDatas)
          }
          .padding(AtlasSpacing.screenHorizontal)
        }
      }
      .background(AtlasColor.background)
      .navigationTitle("Edit Place")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { showingEdit = false }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: saveEdits)
            .disabled(editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
      // Seeded here rather than in the toolbar button that presents the sheet:
      // doing it there races the sheet's first layout and can leave Save disabled
      // against stale state.
      .onAppear {
        editName = place.name
        editNotes = place.notes
        editCategory = place.category
        editPhotoDatas = place.sortedPhotos.map(\.data)
      }
    }
  }

  private func saveEdits() {
    do {
      try repository.updatePlace(
        place,
        name: editName,
        notes: editNotes,
        category: editCategory,
        photoDatas: editPhotoDatas
      )
      showingEdit = false
    } catch {
      AtlasLog.library.error("Failed to update place: \(error.localizedDescription, privacy: .public)")
    }
  }

  private func deletePlace() {
    do {
      try repository.deletePlace(place)
      dismiss()
    } catch {
      AtlasLog.library.error("Failed to delete place: \(error.localizedDescription, privacy: .public)")
    }
  }

  private func move(to collection: Collection) {
    do {
      try repository.movePlace(place, to: collection)
      dismiss()
    } catch {
      AtlasLog.library.error("Failed to move place: \(error.localizedDescription, privacy: .public)")
    }
  }
}
