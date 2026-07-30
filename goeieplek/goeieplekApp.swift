import SwiftUI
import SwiftData

@main
struct goeieplekApp: App {
  let modelContainer: ModelContainer

  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(modelContainer)
    }
  }

  init() {
    let schema = Schema([Collection.self, Place.self])
    let config = ModelConfiguration("Atlas", schema: schema)
    do {
      modelContainer = try ModelContainer(for: schema, configurations: config)
    } catch {
      fatalError("Failed to initialize ModelContainer: \(error)")
    }
  }
}
