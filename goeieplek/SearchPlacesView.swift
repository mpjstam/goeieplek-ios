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

        if searchResults.isEmpty && !searchText.isEmpty {
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
                  .foregroundStyle(.primary)
                if let address = item.placemark.formattedAddress {
                  Text(address)
                    .font(.caption)
                    .foregroundStyle(.gray)
                }
              }
            }
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
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            if let location = selectedLocation, let place = selectedPlace {
              onPlaceSelected(place.name ?? "Place", location.latitude, location.longitude)
            }
          }
          .disabled(selectedLocation == nil)
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
