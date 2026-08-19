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
