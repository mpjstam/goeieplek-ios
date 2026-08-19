import SwiftUI
import SwiftData
import MapKit

/// Screen 05 — Map. The whole library at a glance.
struct MapTabView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(MapFocusRequest.self) private var mapFocus
  @State private var viewModel: MapViewModel?
  @State private var navigationPath: [NavigationDestination] = []
  @State private var position: MapCameraPosition = .automatic
  @State private var selectedPlaceID: String?

  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        Text("Kaart")
          .font(AtlasFont.screenTitle)
          .foregroundStyle(AtlasColor.text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.top, AtlasSpacing.s)
          .padding(.bottom, 14)

        AtlasDivider()

        if let viewModel {
          map(viewModel)
          AtlasDivider()
          summaryBar(viewModel)
        } else {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .background(AtlasColor.background)
      .toolbar(.hidden, for: .navigationBar)
      .navigationDestination(for: NavigationDestination.self) { destination in
        if case .place(let place) = destination {
          PlaceDetailView(
            place: place,
            repository: CollectionsRepository(modelContext: modelContext)
          )
        }
      }
    }
    .onAppear {
      if viewModel == nil {
        viewModel = MapViewModel(modelContext: modelContext)
      }
      viewModel?.load()
      applyPendingFocus()
    }
    .onChange(of: mapFocus.place) { _, _ in
      applyPendingFocus()
    }
  }

  /// Consumes a cross-tab focus request (see `MapFocusRequest`), centering the
  /// map on the requested place. Clears the active category filter first so a
  /// place outside it isn't zoomed to with no marker to show for it.
  private func applyPendingFocus() {
    guard let place = mapFocus.place else { return }
    navigationPath = []
    viewModel?.selectedCategory = nil
    position = .region(
      MKCoordinateRegion(
        center: place.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    )
    mapFocus.place = nil
  }

  private func map(_ viewModel: MapViewModel) -> some View {
    Map(position: $position, selection: $selectedPlaceID) {
      ForEach(viewModel.visiblePlaces) { place in
        Marker(place.name, coordinate: place.coordinate)
          .tint(AtlasColor.accent)
          .tag(place.id)
      }
    }
    .mapStyle(.standard)
    .onChange(of: selectedPlaceID) { _, id in
      guard let id, let place = viewModel.visiblePlaces.first(where: { $0.id == id }) else { return }
      navigationPath.append(.place(place))
      selectedPlaceID = nil
    }
  }

  private func summaryBar(_ viewModel: MapViewModel) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(viewModel.summary)
          .font(AtlasFont.action)
          .foregroundStyle(AtlasColor.text)
        Text(viewModel.subtitle)
          .font(AtlasFont.caption)
          .foregroundStyle(AtlasColor.textTertiary)
      }
      .accessibilityElement(children: .combine)

      Spacer()

      Menu {
        Button("Alle categorieën") { viewModel.selectedCategory = nil }
        ForEach(viewModel.categories, id: \.self) { category in
          Button(category.capitalized) { viewModel.selectedCategory = category }
        }
      } label: {
        AtlasTag(text: viewModel.filterLabel, style: .outline)
      }
      .accessibilityLabel("Filter op categorie, nu \(viewModel.filterLabel)")
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, AtlasSpacing.l)
  }
}
