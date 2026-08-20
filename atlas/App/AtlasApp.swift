import SwiftUI
import SwiftData

@main
struct AtlasApp: App {
  let modelContainer: ModelContainer

  var body: some Scene {
    WindowGroup {
      RootView()
        .modelContainer(modelContainer)
    }
  }

  init() {
    AtlasFont.register()
    AtlasAppearance.apply()

    let schema = Schema([Collection.self, Place.self, Photo.self, Category.self])
    // cloudKitDatabase defaults to .automatic, which — combined with the iCloud/CloudKit
    // entitlement already present — is enough on its own to crash at launch: CloudKit
    // requires every relationship to be optional, and Collection.places / Place.photos
    // (see Models.swift) aren't yet. Keep this explicit .none until those are fixed;
    // do not remove it just because the entitlement looks fully configured.
    let config = ModelConfiguration("Atlas", schema: schema, cloudKitDatabase: .none)
    do {
      modelContainer = try ModelContainer(for: schema, configurations: config)
    } catch {
      fatalError("Failed to initialize ModelContainer: \(error)")
    }

    let categoriesRepository = CategoriesRepository(modelContext: modelContainer.mainContext)
    try? categoriesRepository.seedDefaultsIfNeeded()
  }
}
