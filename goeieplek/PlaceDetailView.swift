import SwiftUI
import MapKit

struct PlaceDetailView: View {
  let place: Place

  @State private var position: MapCameraPosition = .automatic

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
