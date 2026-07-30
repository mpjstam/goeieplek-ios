import SwiftUI
import MapKit

struct PlaceDetailView: View {
  let place: Place
  let repository: CollectionsRepository

  @State private var position: MapCameraPosition = .automatic
  @State private var showingEdit = false
  @State private var editName = ""
  @State private var editNotes = ""
  @State private var editCategory = "restaurant"
  @State private var showingDeleteConfirm = false
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          Text(place.name)
            .font(.title2)
            .fontWeight(.bold)

          if !place.notes.isEmpty {
            Text(place.notes)
              .font(.body)
              .foregroundStyle(.secondary)
          }

          HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
              Text("Latitude")
                .font(.caption)
                .foregroundStyle(.secondary)
              Text(String(format: "%.4f", place.latitude))
                .font(.caption)
                .monospaced()
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Longitude")
                .font(.caption)
                .foregroundStyle(.secondary)
              Text(String(format: "%.4f", place.longitude))
                .font(.caption)
                .monospaced()
            }

            Spacer()
          }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(8)

        Map(position: $position) {
          Marker(place.name, coordinate: place.coordinate)
        }
        .mapStyle(.standard)
        .frame(height: 300)
        .cornerRadius(8)

        VStack(alignment: .leading, spacing: 8) {
          Text("Category")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(place.category.capitalized)
            .font(.body)
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(8)

        VStack(alignment: .leading, spacing: 8) {
          Text("Created")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(place.createdAt.formatted(date: .abbreviated, time: .shortened))
            .font(.caption)
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(8)

        Spacer()
      }
      .padding()
    }
    .navigationTitle("Place")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button(action: {
          editName = place.name
          editNotes = place.notes
          editCategory = place.category
          showingEdit = true
        }) {
          Image(systemName: "pencil")
            .foregroundStyle(.blue)
        }
        Button(action: {
          showingDeleteConfirm = true
        }) {
          Image(systemName: "trash")
            .foregroundStyle(.red)
        }
      }
    }
    .confirmationDialog("Delete Place", isPresented: $showingDeleteConfirm) {
      Button("Delete", role: .destructive) {
        do {
          try repository.deletePlace(place)
          dismiss()
        } catch {
          print("Error deleting place: \(error)")
        }
      }
    } message: {
      Text("Are you sure you want to delete this place? This action cannot be undone.")
    }
    .sheet(isPresented: $showingEdit) {
      NavigationStack {
        Form {
          Section("Name") {
            TextField("Place name", text: $editName)
          }
          Section("Notes") {
            TextEditor(text: $editNotes)
              .frame(height: 100)
          }
          Section("Category") {
            Picker("Category", selection: $editCategory) {
              Text("Restaurant").tag("restaurant")
              Text("Hotel").tag("hotel")
              Text("Viewpoint").tag("viewpoint")
              Text("Activity").tag("activity")
              Text("Parking").tag("parking")
              Text("Other").tag("other")
            }
          }
        }
        .navigationTitle("Edit Place")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              showingEdit = false
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              do {
                try repository.updatePlace(place, name: editName, notes: editNotes, category: editCategory)
                showingEdit = false
              } catch {
                print("Error updating place: \(error)")
              }
            }
            .disabled(editName.isEmpty)
          }
        }
      }
    }
    .onAppear {
      position = .region(
        MKCoordinateRegion(
          center: place.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
      )
    }
  }
}
