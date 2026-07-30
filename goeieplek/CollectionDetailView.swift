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

  var body: some View {
    NavigationStack {
      Group {
        if collection.places.isEmpty {
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
        } else {
          List(collection.places) { place in
            NavigationLink(destination: PlaceDetailView(place: place)) {
              VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                  .font(.headline)
                if !place.notes.isEmpty {
                  Text(place.notes)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                }
                Text("\(place.category.capitalized)")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
              }
            }
          }
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
              Text(selectedPlaceName)
                .font(.headline)
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
            }
          }
        }
      }
    }
  }

  private func resetForm() {
    selectedPlaceName = ""
    placeNotes = ""
    placeCategory = "restaurant"
  }
}
