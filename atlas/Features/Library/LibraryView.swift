import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import OSLog

/// Screen 02 — Library. The home tab: your collections.
///
/// The navigation bar is hidden on this root screen because the design's header is
/// custom (mark + wordmark + two actions), which a native large title cannot express.
/// Pushed screens keep the native bar so the back button and interactive pop gesture
/// continue to work.
struct LibraryView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel: CollectionsViewModel?
  @State private var newCollectionName = ""
  @State private var showingNewCollection = false
  @State private var showingCategories = false
  @State private var navigationPath: [NavigationDestination] = []
  @State private var collectionPendingDeletion: Collection?
  @State private var showingImporter = false
  @State private var importErrorMessage: String?

  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        header
        AtlasDivider()
        content
      }
      .background(AtlasColor.background)
      .toolbar(.hidden, for: .navigationBar)
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case .collection(let collection):
          CollectionDetailView(
            collection: collection,
            repository: CollectionsRepository(modelContext: modelContext),
            navigationPath: $navigationPath
          )
        case .place(let place):
          PlaceDetailView(
            place: place,
            repository: CollectionsRepository(modelContext: modelContext)
          )
        }
      }
      .sheet(isPresented: $showingCategories) {
        CategoriesView(repository: CategoriesRepository(modelContext: modelContext))
      }
      .sheet(isPresented: $showingNewCollection) { newCollectionSheet }
      .confirmationDialog(
        deletionMessage,
        isPresented: deletionBinding,
        titleVisibility: .visible
      ) {
        Button("Delete", role: .destructive) {
          if let collection = collectionPendingDeletion {
            viewModel?.deleteCollection(collection)
          }
          collectionPendingDeletion = nil
        }
        Button("Cancel", role: .cancel) {
          collectionPendingDeletion = nil
        }
      }
      .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
        switch result {
        case .success(let url):
          importFile(from: url)
        case .failure(let error):
          AtlasLog.library.error("Import picker failed: \(error.localizedDescription, privacy: .public)")
          importErrorMessage = "Couldn't open that file."
        }
      }
      .alert("Import Failed", isPresented: importErrorBinding) {
        Button("OK", role: .cancel) { importErrorMessage = nil }
      } message: {
        Text(importErrorMessage ?? "")
      }
    }
    .onAppear {
      if viewModel == nil {
        viewModel = CollectionsViewModel(modelContext: modelContext)
      }
    }
  }

  // MARK: - Header

  private var header: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 20) {
        Spacer()
        Button { showingCategories = true } label: {
          Image(systemName: "tag")
            .font(.title3)
        }
        .accessibilityLabel("Manage categories")

        Menu {
          Button {
            showingNewCollection = true
          } label: {
            Label("New Collection", systemImage: "plus")
          }
          Button {
            showingImporter = true
          } label: {
            Label("Import…", systemImage: "square.and.arrow.down")
          }
          ShareLink(
            "Back Up All Collections…",
            item: SharedLibrary(viewModel?.collections ?? []),
            preview: SharePreview("Goeieplek Backup")
          )
          .disabled(viewModel?.collections.isEmpty ?? true)
        } label: {
          Image(systemName: "plus")
            .font(.title3)
        }
        .accessibilityLabel("Add collection")
      }
      .foregroundStyle(AtlasColor.text)

      HStack(spacing: 10) {
        // The zoomed rainbow-arc crop used on the actual App Icon — deliberately
        // not `AtlasMark` (the full arc-and-pin drawing used on the splash screen).
        Image("AppIconCrop")
          .resizable()
          .frame(width: 28, height: 28)
          .accessibilityHidden(true)
        Text("Goeieplek")
          .font(AtlasFont.wordmark)
          .foregroundStyle(AtlasColor.text)
      }
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.top, AtlasSpacing.s)
    .padding(.bottom, 18)
  }

  // MARK: - Content

  @ViewBuilder
  private var content: some View {
    if let viewModel {
      if viewModel.collections.isEmpty {
        emptyState
      } else {
        collectionsList(viewModel.collections)
      }
    } else {
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  /// A `List` rather than the `ScrollView`/`LazyVStack` used elsewhere in this
  /// screen family — `.swipeActions` only exists on `List` rows, and a hand-rolled
  /// swipe gesture is exactly the kind of custom control `Claude.md` says to avoid
  /// when a native one exists. Every row modifier below strips List's own chrome
  /// (insets, separator, background) so it still reads as the design's flat list;
  /// each row draws its own trailing `AtlasDivider` in its place.
  private func collectionsList(_ collections: [Collection]) -> some View {
    List {
      ForEach(collections) { collection in
        Button {
          navigationPath.append(.collection(collection))
        } label: {
          collectionRow(collection)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(AtlasColor.background)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button(role: .destructive) {
            collectionPendingDeletion = collection
          } label: {
            Label("Delete", systemImage: "trash")
          }
          .accessibilityLabel("Delete \(collection.name)")
        }
      }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .environment(\.defaultMinListRowHeight, 0)
  }

  private func collectionRow(_ collection: Collection) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(alignment: .leading, spacing: 6) {
        Text(collection.name)
          .font(AtlasFont.collectionRow)
          .foregroundStyle(AtlasColor.text)

        if !collection.notes.isEmpty {
          Text(collection.notes)
            .font(AtlasFont.body)
            .foregroundStyle(AtlasColor.textSecondary)
            .multilineTextAlignment(.leading)
        }

        AtlasTag(text: placeCount(collection.places.count), style: .outline)
          .padding(.top, 2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, AtlasSpacing.screenHorizontal)
      .padding(.vertical, 18)

      AtlasDivider()
    }
    .contentShape(Rectangle())
  }

  // MARK: - Deletion

  private var deletionBinding: Binding<Bool> {
    Binding(
      get: { collectionPendingDeletion != nil },
      set: { if !$0 { collectionPendingDeletion = nil } }
    )
  }

  private var deletionMessage: String {
    guard let collection = collectionPendingDeletion else { return "" }
    let count = collection.places.count
    if count == 0 {
      return "Delete “\(collection.name)”?"
    }
    let placeWord = count == 1 ? "place" : "places"
    return "Delete “\(collection.name)” and its \(count) \(placeWord)? This can't be undone."
  }

  /// `AtlasTag` takes a plain `String`, so the `^[…](inflect:)` markup would render
  /// literally — the pluralisation is done here instead.
  private func placeCount(_ count: Int) -> String {
    count == 1 ? "1 place" : "\(count) places"
  }

  private var emptyState: some View {
    VStack(spacing: AtlasSpacing.m) {
      Image(systemName: "mappin.circle")
        .font(.system(size: 44))
        .foregroundStyle(AtlasColor.neutral400)
      Text("No collections yet")
        .font(AtlasFont.rowTitle)
        .foregroundStyle(AtlasColor.text)
      Text("Create one to start collecting places")
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - Import

  private var importErrorBinding: Binding<Bool> {
    Binding(
      get: { importErrorMessage != nil },
      set: { if !$0 { importErrorMessage = nil } }
    )
  }

  /// `.fileImporter` hands back a security-scoped URL (the file may live in another
  /// app's iCloud container) — must bracket the read with start/stop or `Data(contentsOf:)`
  /// can fail silently. Tries a full-library backup first, falling back to a
  /// single shared collection — both are `.json`, so the picker can't tell them
  /// apart up front.
  private func importFile(from url: URL) {
    let didStartAccessing = url.startAccessingSecurityScopedResource()
    defer {
      if didStartAccessing { url.stopAccessingSecurityScopedResource() }
    }
    let categoriesRepository = CategoriesRepository(modelContext: modelContext)
    if let library = try? SharedLibrary.decode(from: url) {
      viewModel?.importLibrary(library, categoriesRepository: categoriesRepository)
      return
    }
    do {
      let shared = try SharedCollection.decode(from: url)
      viewModel?.importCollection(shared, categoriesRepository: categoriesRepository)
    } catch {
      importErrorMessage = error.localizedDescription
    }
  }

  // MARK: - New collection

  private var newCollectionSheet: some View {
    NavigationStack {
      Form {
        TextField("Collection name", text: $newCollectionName)
      }
      .navigationTitle("New Collection")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            showingNewCollection = false
            newCollectionName = ""
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Create") {
            let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            viewModel?.createCollection(name: trimmed)
            showingNewCollection = false
            newCollectionName = ""
          }
          .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}
