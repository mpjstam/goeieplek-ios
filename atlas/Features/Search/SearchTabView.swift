import SwiftUI
import SwiftData
import OSLog

/// Screen 06 — Search. Find a place to add, from anywhere in the app.
///
/// The design shows an inline **Add** on each result but does not say which
/// collection receives it, so Add offers the collection list. When only one
/// collection exists it is chosen without a prompt, keeping capture fast.
struct SearchTabView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PendingShareRequest.self) private var pendingShare
  @FocusState private var isSearchFieldFocused: Bool

  @State private var searchText = ""
  @State private var searchCompleter = PlaceSearchCompleter()
  /// A single already-resolved result pinned above the suggestion list — used
  /// only by `presentSingleResult`'s no-collections fallback, since a
  /// suggestion from `searchCompleter` can't represent an already-resolved
  /// current-location/pasted-link result.
  @State private var pinnedResult: PlaceSearchResult?
  @State private var selectedID: String?
  @State private var collections: [Collection] = []
  @State private var pendingAdd: PendingAdd?
  @State private var isLocating = false
  @State private var isPasting = false
  @State private var locationErrorMessage: String?
  @State private var shareNeedingCollection: PlaceSearchResult?
  @State private var incomingShares: [IncomingShare] = []
  /// Set when the user has no collections yet and taps "New Collection" from
  /// a result — the sheet it drives creates the collection, then saves this
  /// already-resolved result straight into it.
  @State private var newCollectionTarget: PlaceSearchResult?
  @State private var newCollectionName = ""

  /// A share handed off from `AtlasShare`, shown as a standing banner rather
  /// than popped as a sheet/dialog the instant it resolves — the extension
  /// can't reliably bring Atlas to the foreground, so by the time this
  /// resolves the user may be looking at something else entirely. The banner
  /// stays put until they notice and tap it, instead of ambushing them.
  ///
  /// Sharing several places in a row before ever opening Atlas queues all of
  /// them (see `MapsShareInbox`), so this is `Identifiable` and each one
  /// resolves and displays independently — a slow or failed one doesn't block
  /// the rest of the stack.
  private struct IncomingShare: Identifiable {
    let id: UUID
    var state: State

    enum State {
      case loading
      case ready(PlaceSearchResult)
      case failed(String)
    }
  }

  @State private var locationService = CurrentLocationService()

  /// A chosen result plus the collection it will be saved into.
  private struct PendingAdd: Identifiable {
    let id = UUID()
    let place: PendingPlace
    let collection: Collection
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Text("Zoeken")
          .font(AtlasFont.screenTitle)
          .foregroundStyle(AtlasColor.text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.top, AtlasSpacing.s)
          .padding(.bottom, 14)

        incomingShareBanner

        AtlasSearchField(text: $searchText, isFocused: $isSearchFieldFocused)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.bottom, 14)

        CurrentLocationRow(isLoading: isLocating, action: useCurrentLocation)
        PasteLocationRow(isLoading: isPasting, action: pasteFromMaps)
        AtlasDivider()
        content
      }
      .background(AtlasColor.background)
      .toolbar(.hidden, for: .navigationBar)
    }
    .onAppear {
      loadCollections()
      resolvePendingShare()
    }
    .onChange(of: searchText) { _, query in updateCompleterQuery(query) }
    .onChange(of: pendingShare.urlStrings) { _, _ in resolvePendingShare() }
    .sheet(item: $pendingAdd) { pending in
      AddPlaceDetailsView(
        place: pending.place,
        onSave: { notes, category, photoDatas in
          save(pending, notes: notes, category: category, photoDatas: photoDatas)
        },
        onCancel: { pendingAdd = nil }
      )
    }
    .sheet(item: $shareNeedingCollection) { result in
      collectionPickerSheet(for: result)
    }
    .sheet(item: $newCollectionTarget) { result in
      newCollectionSheet(for: result)
    }
    .alert(
      "Locatie niet beschikbaar",
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

  @ViewBuilder
  private var incomingShareBanner: some View {
    ForEach(incomingShares) { share in
      VStack(spacing: 0) {
        switch share.state {
        case .loading:
          bannerRow(
            icon: "mappin.circle.fill",
            title: "Gedeelde locatie importeren…",
            subtitle: "Vanuit Maps"
          ) {
            ProgressView()
          }
        case .ready(let result):
          Button {
            incomingShares.removeAll { $0.id == share.id }
            presentSingleResult(result)
          } label: {
            bannerRow(
              icon: "mappin.circle.fill",
              title: result.name,
              subtitle: "\(result.subtitle) — tik om toe te voegen"
            ) {
              Image(systemName: "chevron.right")
                .foregroundStyle(AtlasColor.textSecondary)
            }
          }
          .buttonStyle(.plain)
        case .failed(let message):
          bannerRow(
            icon: "exclamationmark.triangle.fill",
            title: "Kon gedeelde locatie niet importeren",
            subtitle: message
          ) {
            Button {
              incomingShares.removeAll { $0.id == share.id }
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(AtlasColor.textSecondary)
            }
            .accessibilityLabel("Sluiten")
          }
        }
        AtlasDivider()
      }
    }
  }

  private func bannerRow<Trailing: View>(
    icon: String,
    title: String,
    subtitle: String,
    @ViewBuilder trailing: () -> Trailing
  ) -> some View {
    HStack(spacing: AtlasSpacing.m) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundStyle(AtlasColor.accent)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(AtlasFont.rowTitle)
          .foregroundStyle(AtlasColor.text)
          .lineLimit(1)
        Text(subtitle)
          .font(AtlasFont.caption)
          .foregroundStyle(AtlasColor.textSecondary)
          .lineLimit(1)
      }
      Spacer(minLength: 0)
      trailing()
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, AtlasSpacing.m)
    .background(AtlasColor.accent100)
  }

  /// A proper modal rather than a `confirmationDialog` — an action sheet needs
  /// a stable source view to anchor its arrow to, and the row that triggers
  /// this (the incoming-share banner) removes itself from the hierarchy in
  /// the same tap that opens the picker, leaving the arrow pointing at
  /// nothing. A sheet has no such anchor to lose.
  private func collectionPickerSheet(for result: PlaceSearchResult) -> some View {
    NavigationStack {
      List(collections) { collection in
        Button {
          begin(result, into: collection)
          shareNeedingCollection = nil
        } label: {
          Text(collection.name)
            .font(AtlasFont.rowTitle)
            .foregroundStyle(AtlasColor.text)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Voeg toe aan collectie")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuleer") { shareNeedingCollection = nil }
        }
      }
    }
    .presentationDetents([.medium])
  }

  /// Reached when there are no collections yet — names one, creates it, and
  /// saves `result` straight into it, so importing your first place doesn't
  /// require a separate trip to the Library tab first.
  private func newCollectionSheet(for result: PlaceSearchResult) -> some View {
    NavigationStack {
      Form {
        TextField("Naam van de collectie", text: $newCollectionName)
      }
      .navigationTitle("Nieuwe collectie")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuleer") {
            newCollectionTarget = nil
            newCollectionName = ""
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Maak aan") { createCollectionAndBegin(result) }
            .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
    .presentationDetents([.medium])
  }

  private func createCollectionAndBegin(_ result: PlaceSearchResult) {
    do {
      guard let collection = try CollectionsRepository(modelContext: modelContext).createCollection(named: newCollectionName) else {
        return
      }
      collections.append(collection)
      newCollectionTarget = nil
      newCollectionName = ""
      begin(result, into: collection)
    } catch {
      AtlasLog.search.error("Failed to create collection: \(error.localizedDescription, privacy: .public)")
    }
  }

  @ViewBuilder
  private var content: some View {
    let isEmpty = pinnedResult == nil && searchCompleter.suggestions.isEmpty
    if isEmpty && !searchText.isEmpty {
      SearchPlaceholder(systemImage: "magnifyingglass", message: "Geen plekken gevonden")
    } else if isEmpty {
      SearchPlaceholder(systemImage: "map", message: "Zoek een plek om toe te voegen")
    } else {
      resultsList
    }
  }

  private var resultsList: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        if let pinnedResult {
          Button {
            isSearchFieldFocused = false
            selectedID = pinnedResult.id
          } label: {
            PlaceResultRow(result: pinnedResult, isSelected: pinnedResult.id == selectedID) {
              // Only ever shown when there are no collections to add to yet —
              // see `pinnedResult`'s doc comment.
              if pinnedResult.id == selectedID {
                newCollectionButton { newCollectionTarget = pinnedResult }
              }
            }
          }
          .buttonStyle(.plain)
          AtlasDivider()
        }

        ForEach(searchCompleter.suggestions) { suggestion in
          Button {
            isSearchFieldFocused = false
            selectedID = suggestion.id
          } label: {
            PlaceResultRow(title: highlightedTitle(suggestion), subtitle: suggestion.subtitle, isSelected: suggestion.id == selectedID) {
              if suggestion.id == selectedID {
                addControl(for: suggestion)
              }
            }
          }
          .buttonStyle(.plain)
          AtlasDivider()
        }
      }
    }
    .scrollDismissesKeyboard(.immediately)
  }

  /// Bolds the substring(s) of a suggestion's title that matched the typed
  /// query — the same highlighting Spotlight/Maps show in their own
  /// suggestion lists, and the main visual payoff of using a completer at all.
  private func highlightedTitle(_ suggestion: PlaceSearchSuggestion) -> AttributedString {
    var attributed = AttributedString(suggestion.title)
    for nsRange in suggestion.titleHighlightRanges {
      guard let stringRange = Range(nsRange, in: suggestion.title),
            let attributedRange = Range(stringRange, in: attributed)
      else { continue }
      attributed[attributedRange].font = AtlasFont.resultTitle.bold()
    }
    return attributed
  }

  @ViewBuilder
  private func addControl(for suggestion: PlaceSearchSuggestion) -> some View {
    if collections.isEmpty {
      newCollectionButton { resolveForNewCollection(suggestion) }
    } else if collections.count == 1, let only = collections.first {
      addButton { resolveAndAdd(suggestion, into: only) }
    } else {
      Menu {
        ForEach(collections) { collection in
          Button(collection.name) { resolveAndAdd(suggestion, into: collection) }
        }
      } label: {
        addLabel
      }
      .accessibilityLabel("Voeg \(suggestion.title) toe aan een collectie")
    }
  }

  /// The suggestion's coordinate is resolved here, on "Add" — the one point in
  /// this flow that actually needs it, rather than up front for every
  /// suggestion the completer returns.
  private func resolveAndAdd(_ suggestion: PlaceSearchSuggestion, into collection: Collection) {
    Task {
      do {
        let result = try await searchCompleter.resolve(suggestion)
        begin(result, into: collection)
      } catch {
        AtlasLog.search.error("Failed to resolve suggestion: \(error.localizedDescription, privacy: .public)")
        locationErrorMessage = error.localizedDescription
      }
    }
  }

  /// Same resolution step as `resolveAndAdd`, but for the no-collections-yet
  /// case — opens `newCollectionSheet` with the resolved result once it's in
  /// hand, instead of adding straight into an (nonexistent) collection.
  private func resolveForNewCollection(_ suggestion: PlaceSearchSuggestion) {
    Task {
      do {
        newCollectionTarget = try await searchCompleter.resolve(suggestion)
      } catch {
        AtlasLog.search.error("Failed to resolve suggestion: \(error.localizedDescription, privacy: .public)")
        locationErrorMessage = error.localizedDescription
      }
    }
  }

  private func addButton(action: @escaping () -> Void) -> some View {
    pillButton("Voeg toe", accessibilityLabel: "Voeg toe aan collectie", action: action)
  }

  private var addLabel: some View {
    pillLabel("Voeg toe")
  }

  /// Shown in place of `addButton` when there are no collections yet to add
  /// into — starts the same "New Collection" flow the Library tab's own
  /// empty state points at, so importing your first place doesn't require a
  /// detour there first.
  private func newCollectionButton(action: @escaping () -> Void) -> some View {
    pillButton("Nieuwe collectie", accessibilityLabel: "Maak een collectie aan en voeg deze plek toe", action: action)
  }

  private func pillButton(_ title: String, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
    Button(action: action) { pillLabel(title) }
      .buttonStyle(.plain)
      .accessibilityLabel(accessibilityLabel)
  }

  private func pillLabel(_ title: String) -> some View {
    Text(title)
      .font(AtlasFont.rowAction)
      .foregroundStyle(AtlasColor.background)
      .padding(.horizontal, 14)
      .padding(.vertical, 6)
      .background(AtlasColor.accent)
  }

  // MARK: - Actions

  private func useCurrentLocation() {
    isSearchFieldFocused = false
    isLocating = true
    Task {
      do {
        presentSingleResult(try await locationService.currentPlace())
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
        presentSingleResult(try await MapsLinkImport.resolveFromClipboard())
      } catch {
        AtlasLog.search.error("Maps paste failed: \(error.localizedDescription, privacy: .public)")
        locationErrorMessage = error.localizedDescription
      }
      isPasting = false
    }
  }

  /// Picks up every link handed off by `RootView` from the `AtlasShare`
  /// extension (see `MapsShareInbox`) and resolves each the same way a pasted
  /// link is — but into the standing `incomingShares` banner stack rather
  /// than straight into a sheet, since resolving can take a moment and the
  /// user may not even be looking at this tab when it finishes. Each queued
  /// share resolves independently so one slow or failed link doesn't hold up
  /// the others.
  private func resolvePendingShare() {
    guard !pendingShare.urlStrings.isEmpty else { return }
    let urlStrings = pendingShare.urlStrings
    pendingShare.urlStrings = []
    for urlString in urlStrings {
      guard let url = URL(string: urlString) else { continue }
      let id = UUID()
      incomingShares.append(IncomingShare(id: id, state: .loading))
      Task {
        do {
          let result = try await MapsLinkImport.resolve(url: url)
          updateIncomingShare(id: id, state: .ready(result))
        } catch {
          AtlasLog.search.error("Shared maps link failed: \(error.localizedDescription, privacy: .public)")
          updateIncomingShare(id: id, state: .failed(error.localizedDescription))
        }
      }
    }
  }

  private func updateIncomingShare(id: UUID, state: IncomingShare.State) {
    guard let index = incomingShares.firstIndex(where: { $0.id == id }) else { return }
    incomingShares[index].state = state
  }

  /// A place from current-location or paste is unambiguous — there's nothing to
  /// browse, so it skips straight to the same add-details sheet a typed search
  /// result reaches after "Add", rather than sitting in the results list waiting
  /// for a tap. Only falls back to the list when there's no collection to add it to.
  private func presentSingleResult(_ result: PlaceSearchResult) {
    if collections.count == 1, let only = collections.first {
      begin(result, into: only)
    } else if collections.count > 1 {
      shareNeedingCollection = result
    } else {
      pinnedResult = result
      selectedID = result.id
    }
  }

  private func begin(_ result: PlaceSearchResult, into collection: Collection) {
    pendingAdd = PendingAdd(
      place: PendingPlace(
        name: result.name,
        latitude: result.latitude,
        longitude: result.longitude
      ),
      collection: collection
    )
  }

  private func save(_ pending: PendingAdd, notes: String, category: String, photoDatas: [Data]) {
    do {
      _ = try CollectionsRepository(modelContext: modelContext).addPlace(
        to: pending.collection,
        name: pending.place.name,
        notes: notes,
        latitude: pending.place.latitude,
        longitude: pending.place.longitude,
        category: category,
        photoDatas: photoDatas
      )
      selectedID = nil
    } catch {
      AtlasLog.search.error("Failed to add place: \(error.localizedDescription, privacy: .public)")
    }
    pendingAdd = nil
  }

  private func loadCollections() {
    do {
      collections = try CollectionsRepository(modelContext: modelContext).fetchCollections()
    } catch {
      AtlasLog.search.error("Failed to load collections: \(error.localizedDescription, privacy: .public)")
    }
  }

  /// `MKLocalSearchCompleter` does its own internal debouncing/coalescing, so
  /// unlike the old `MKLocalSearch`-per-keystroke approach this needs no
  /// manual `Task.sleep` debounce of its own.
  private func updateCompleterQuery(_ query: String) {
    selectedID = nil
    pinnedResult = nil
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      searchCompleter.clear()
    } else {
      searchCompleter.queryFragment = trimmed
    }
  }
}
