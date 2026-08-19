import SwiftUI
import SwiftData

/// Screen 08 — Categories. Manage the vocabulary.
///
/// The design puts RENAME and delete inline on every row rather than behind a
/// swipe, so both actions are discoverable and reachable without a gesture — which
/// also makes them available to VoiceOver and Switch Control users directly.
struct CategoriesView: View {
  let repository: CategoriesRepository

  @Environment(\.dismiss) private var dismiss
  @Query(sort: \Category.sortOrder) private var categories: [Category]

  @State private var showingAdd = false
  @State private var newCategoryName = ""
  @State private var renamingCategory: Category?
  @State private var renameText = ""
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Text("Categorieën")
          .font(AtlasFont.screenTitle)
          .foregroundStyle(AtlasColor.text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.bottom, AtlasSpacing.l)

        AtlasDivider()

        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(categories) { category in
              row(category)
              AtlasDivider()
            }
          }
        }
      }
      .background(AtlasColor.background)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Gereed") { dismiss() }
            .font(AtlasFont.body)
            .foregroundStyle(AtlasColor.textSecondary)
        }
        ToolbarItem(placement: .primaryAction) {
          Button { showingAdd = true } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Categorie toevoegen")
        }
      }
      .tint(AtlasColor.accent)
      .sheet(isPresented: $showingAdd) { addSheet }
      .alert("Categorie hernoemen", isPresented: renamingBinding) {
        TextField("Naam van de categorie", text: $renameText)
        Button("Annuleer", role: .cancel) { renamingCategory = nil }
        Button("Bewaar", action: rename)
      }
      .alert("Categorie kon niet bewaard worden", isPresented: errorBinding) {
        Button("OK", role: .cancel) { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "")
      }
    }
  }

  private func row(_ category: Category) -> some View {
    HStack(spacing: 18) {
      Text(category.name.capitalized)
        .font(AtlasFont.rowTitle)
        .foregroundStyle(AtlasColor.text)

      Spacer(minLength: 0)

      Button {
        renamingCategory = category
        renameText = category.name
      } label: {
        Text("Hernoem")
          .font(AtlasFont.rowAction)
          .textCase(.uppercase)
          .tracking(0.44)
          .foregroundStyle(AtlasColor.accent)
      }
      .accessibilityLabel("Hernoem \(category.name)")

      Button {
        delete(category)
      } label: {
        Image(systemName: "trash")
          .font(AtlasFont.rowTitle)
          .foregroundStyle(AtlasColor.text)
      }
      .accessibilityLabel("Verwijder \(category.name)")
    }
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, AtlasSpacing.l)
  }

  private var addSheet: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AtlasDivider()
        AtlasFormField(label: "Naam") {
          TextField("Naam van de categorie", text: $newCategoryName)
            .font(AtlasFont.bodyLarge)
            .atlasInputBackground()
        }
        .padding(AtlasSpacing.screenHorizontal)
        Spacer()
      }
      .background(AtlasColor.background)
      .navigationTitle("Nieuwe categorie")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuleer") {
            showingAdd = false
            newCategoryName = ""
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Voeg toe", action: addCategory)
            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
      .tint(AtlasColor.accent)
    }
  }

  // MARK: - Bindings

  private var renamingBinding: Binding<Bool> {
    Binding(
      get: { renamingCategory != nil },
      set: { if !$0 { renamingCategory = nil } }
    )
  }

  private var errorBinding: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    )
  }

  // MARK: - Actions

  private func addCategory() {
    do {
      _ = try repository.addCategory(name: newCategoryName)
      newCategoryName = ""
      showingAdd = false
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func rename() {
    guard let category = renamingCategory else { return }
    do {
      try repository.renameCategory(category, to: renameText)
    } catch {
      errorMessage = error.localizedDescription
    }
    renamingCategory = nil
  }

  private func delete(_ category: Category) {
    do {
      try repository.deleteCategory(category)
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
