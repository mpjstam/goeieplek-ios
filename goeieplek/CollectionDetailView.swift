import SwiftUI

struct CollectionDetailView: View {
  let collection: Collection
  let repository: CollectionsRepository

  @State private var showingSearch = false
  @State private var selectedPlaceName = ""
  @State private var selectedPlaceLat = 0.0
  @State private var selectedPlaceLng = 0.0
  @State private var showingDetails = false
  @State private var placeNotes = ""
  @State private var placeCategory = "restaurant"
  @State private var navigationPath: [Place] = []

  var body: some View {
    NavigationStack(path: $navigationPath) {
      Group {
        if collection.places.isEmpty {
          emptyStateView
        } else {
          placesList
        }
      }
      .navigationDestination(for: Place.self) { place in
        PlaceDetailView(place: place, repository: repository)
      }
    }
    .navigationTitle(collection.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: { showingSearch = true }) {
          Image(systemName: "plus")
        }
      }
    }
    .sheet(isPresented: $showingSearch) {
      SearchPlacesView { name, lat, lng in
        selectedPlaceName = name
        selectedPlaceLat = lat
        selectedPlaceLng = lng
        showingSearch = false
        showingDetails = true
      }
    }
    .sheet(isPresented: $showingDetails) {
      NavigationStack {
        Form {
          Section("Place") {
            Text(selectedPlaceName.isEmpty ? "No place selected" : selectedPlaceName)
              .font(.headline)
              .foregroundStyle(selectedPlaceName.isEmpty ? .gray : .primary)
          }
          Section("Notes") {
            TextEditor(text: $placeNotes)
              .frame(height: 100)
          }
          Section("Category") {
            Picker("Category", selection: $placeCategory) {
              Text("Restaurant").tag("restaurant")
              Text("Hotel").tag("hotel")
              Text("Viewpoint").tag("viewpoint")
              Text("Activity").tag("activity")
              Text("Parking").tag("parking")
              Text("Other").tag("other")
            }
          }
        }
        .navigationTitle("Place Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              showingDetails = false
              resetForm()
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              do {
                _ = try repository.addPlace(
                  to: collection,
                  name: selectedPlaceName,
                  notes: placeNotes,
                  latitude: selectedPlaceLat,
                  longitude: selectedPlaceLng,
                  category: placeCategory
                )
                showingDetails = false
                resetForm()
              } catch {
                print("Error adding place: \(error)")
              }
            }
            .disabled(selectedPlaceName.isEmpty)
          }
        }
      }
    }
  }

  private var emptyStateView: some View {
    VStack(spacing: 12) {
      Image(systemName: "mappin")
        .font(.system(size: 40))
        .foregroundStyle(.gray)
      Text("No places yet")
        .font(.headline)
      Text("Search or add your first place to this collection")
        .font(.caption)
        .foregroundStyle(.gray)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray.opacity(0.05))
  }

  private var placesList: some View {
    List(collection.places) { place in
      Button(action: { navigationPath.append(place) }) {
        VStack(alignment: .leading, spacing: 4) {
          Text(place.name)
            .font(.headline)
            .foregroundStyle(.primary)
          if !place.notes.isEmpty {
            Text(place.notes)
              .font(.caption)
              .foregroundStyle(.gray)
              .lineLimit(1)
          }
          Text(place.category.capitalized)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
      }
    }
  }

  private func resetForm() {
    selectedPlaceName = ""
    placeNotes = ""
    placeCategory = "restaurant"
  }
}
