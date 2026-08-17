import SwiftUI
import MapKit
import OSLog

/// External place search presented from inside a collection, where the destination
/// is already known.
///
/// This path keeps the map preview and explicit confirm step: picking the wrong
/// "De Kaaskamer" is easy, and the preview is what makes the choice verifiable.
/// The Search tab omits it because the design specifies a direct Add there.
struct SearchPlacesView: View {
  let onPlaceSelected: (String, Double, Double) -> Void

  @Environment(\.dismiss) private var dismiss
  @FocusState private var isSearchFieldFocused: Bool

  @State private var searchText = ""
  @State private var results: [PlaceSearchResult] = []
  @State private var selected: PlaceSearchResult?
  @State private var searchTask: Task<Void, Never>?
  @State private var isLocating = false
  @State private var isPasting = false
  @State private var locationErrorMessage: String?

  private let service = PlaceSearchService()
  @State private var locationService = CurrentLocationService()

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AtlasSearchField(text: $searchText, isFocused: $isSearchFieldFocused)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.bottom, 14)

        CurrentLocationRow(isLoading: isLocating, action: useCurrentLocation)
        PasteLocationRow(isLoading: isPasting, action: pasteFromMaps)
        AtlasDivider()
        content
      }
      .background(AtlasColor.background)
      .navigationTitle("Search Place")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
      .tint(AtlasColor.accent)
      .onChange(of: searchText) { _, query in
        scheduleSearch(query)
      }
      .alert(
        "Location Unavailable",
        isPresented: Binding(
          get: { locationErrorMessage != nil },
          set: { if !$0 { locationErrorMessage = nil } }
        )
      ) {
        Button("OK", role: .cancel) { locationErrorMessage = nil }
      } message: {
        Text(locationErrorMessage ?? "")
      }
    }
  }

  private func useCurrentLocation() {
    isSearchFieldFocused = false
    isLocating = true
    Task {
      do {
        selected = try await locationService.currentPlace()
      } catch {
        AtlasLog.search.error("Current location failed: \(error.localizedDescription, privacy: .public)")
        locationErrorMessage = error.localizedDescription
      }
      isLocating = false
    }
  }

  private func pasteFromMaps() {
    isSearchFieldFocused = false
    isPasting = true
    Task {
      do {
        selected = try await MapsLinkImport.resolveFromClipboard()
      } catch {
        AtlasLog.search.error("Maps paste failed: \(error.localizedDescription, privacy: .public)")
        locationErrorMessage = error.localizedDescription
      }
      isPasting = false
    }
  }

  @ViewBuilder
  private var content: some View {
    if let selected {
      preview(selected)
    } else if results.isEmpty && !searchText.isEmpty {
      SearchPlaceholder(systemImage: "magnifyingglass", message: "No places found")
    } else if results.isEmpty {
      SearchPlaceholder(systemImage: "map", message: "Search for a place")
    } else {
      resultsList
    }
  }

  private var resultsList: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(results) { result in
          Button {
            isSearchFieldFocused = false
            selected = result
          } label: {
            PlaceResultRow(result: result) { EmptyView() }
          }
          .buttonStyle(.plain)
          AtlasDivider()
        }
      }
    }
    .scrollDismissesKeyboard(.immediately)
  }

  private func preview(_ result: PlaceSearchResult) -> some View {
    VStack(spacing: 0) {
      Map(position: .constant(.region(
        MKCoordinateRegion(
          center: result.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
      )), interactionModes: []) {
        Marker(result.name, coordinate: result.coordinate)
          .tint(AtlasColor.accent)
      }
      .frame(height: 200)
      .accessibilityLabel("Map showing \(result.name)")

      VStack(alignment: .leading, spacing: AtlasSpacing.xs) {
        Text(result.name)
          .font(AtlasFont.rowTitle)
          .foregroundStyle(AtlasColor.text)
        if !result.subtitle.isEmpty {
          Text(result.subtitle)
            .font(AtlasFont.caption)
            .foregroundStyle(AtlasColor.textSecondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(AtlasSpacing.screenHorizontal)

      Button {
        onPlaceSelected(result.name, result.latitude, result.longitude)
      } label: {
        Text("Confirm & Add Details")
          .font(AtlasFont.action)
          .foregroundStyle(AtlasColor.background)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(AtlasColor.accent)
      }
      .buttonStyle(.plain)
      .padding(.horizontal, AtlasSpacing.screenHorizontal)

      Button("Choose a different place") {
        selected = nil
      }
      .font(AtlasFont.body)
      .foregroundStyle(AtlasColor.accent)
      .padding(.top, AtlasSpacing.m)

      Spacer()
    }
  }

  /// Debounced so a fast typist does not fire a request per keystroke.
  private func scheduleSearch(_ query: String) {
    searchTask?.cancel()
    selected = nil

    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      results = []
      return
    }

    searchTask = Task {
      try? await Task.sleep(for: .milliseconds(250))
      guard !Task.isCancelled else { return }
      do {
        let found = try await service.search(query)
        guard !Task.isCancelled else { return }
        results = found
      } catch {
        AtlasLog.search.error("Place search failed: \(error.localizedDescription, privacy: .public)")
        results = []
      }
    }
  }
}
