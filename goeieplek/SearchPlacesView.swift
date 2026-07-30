import SwiftUI
import MapKit

struct SearchPlacesView: View {
  @State private var searchText = ""
  @State private var searchResults: [MKMapItem] = []
  @State private var selectedLocation: CLLocationCoordinate2D?
  @State private var selectedPlace: MKMapItem?
  let onPlaceSelected: (String, Double, Double) -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
            .foregroundStyle(.gray)
          TextField("Search places...", text: $searchText)
            .onChange(of: searchText) { _, newValue in
              performSearch(newValue)
            }
          if !searchText.isEmpty {
            Button(action: { searchText = "" }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(20)
        .shadow(radius: 2)
        .padding()

        if selectedLocation != nil {
          VStack(spacing: 12) {
            Map(position: .constant(.region(
              MKCoordinateRegion(
                center: selectedLocation!,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
              )
            ))) {
              Marker(selectedPlace?.name ?? "Selected Place", coordinate: selectedLocation!)
            }
            .mapStyle(.standard)
            .frame(height: 200)
            .cornerRadius(8)
            .padding()

            VStack(alignment: .leading, spacing: 8) {
              Text(selectedPlace?.name ?? "Place")
                .font(.headline)
              if let address = selectedPlace?.placemark.formattedAddress {
                Text(address)
                  .font(.caption)
                  .foregroundStyle(.gray)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.gray.opacity(0.05))
            .cornerRadius(8)
            .padding()

            Button(action: {
              if let location = selectedLocation, let place = selectedPlace {
                onPlaceSelected(place.name ?? "Place", location.latitude, location.longitude)
              }
            }) {
              Text("Confirm & Add Details")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(8)
            }
            .padding()

            Spacer()
          }
        } else if searchResults.isEmpty && !searchText.isEmpty {
          VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 40))
              .foregroundStyle(.gray)
            Text("No places found")
              .font(.caption)
              .foregroundStyle(.gray)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.gray.opacity(0.05))
        } else if !searchResults.isEmpty {
          List(searchResults, id: \.self) { item in
            Button(action: {
              selectedPlace = item
              selectedLocation = item.placemark.coordinate
            }) {
              VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Unknown")
                  .fontWeight(.semibold)
                  .foregroundStyle(selectedPlace?.name == item.name ? .blue : .primary)
                if let address = item.placemark.formattedAddress {
                  Text(address)
                    .font(.caption)
                    .foregroundStyle(.gray)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())
            }
            .listRowBackground(
              selectedPlace?.name == item.name
                ? Color.blue.opacity(0.1)
                : Color.clear
            )
          }
        } else {
          VStack(spacing: 12) {
            Image(systemName: "map")
              .font(.system(size: 40))
              .foregroundStyle(.gray)
            Text("Search for a place")
              .font(.caption)
              .foregroundStyle(.gray)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.gray.opacity(0.05))
        }
      }
      .navigationTitle("Search Place")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            // Dismiss handled by presentation binding
          }
        }
      }
    }
  }

  private func performSearch(_ query: String) {
    guard !query.isEmpty else {
      searchResults = []
      return
    }

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 52.1, longitude: 5.3),
      span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    )

    let search = MKLocalSearch(request: request)
    search.start { response, error in
      if let response = response {
        DispatchQueue.main.async {
          self.searchResults = response.mapItems
        }
      }
    }
  }
}

extension CLPlacemark {
  var formattedAddress: String? {
    var parts: [String] = []
    if let locality = locality { parts.append(locality) }
    if let administrativeArea = administrativeArea { parts.append(administrativeArea) }
    return parts.isEmpty ? nil : parts.joined(separator: ", ")
  }
}
