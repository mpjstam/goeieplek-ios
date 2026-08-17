import Foundation
import OSLog

/// Central loggers for Atlas.
///
/// `Architecture.md` requires OSLog over `print()` so that failures carry
/// context and are visible in Console.app without a debugger attached.
enum AtlasLog {
  private static let subsystem = Bundle.main.bundleIdentifier ?? "studiostam.atlas"

  static let designSystem = Logger(subsystem: subsystem, category: "DesignSystem")
  static let persistence = Logger(subsystem: subsystem, category: "Persistence")
  static let library = Logger(subsystem: subsystem, category: "Library")
  static let map = Logger(subsystem: subsystem, category: "Map")
  static let search = Logger(subsystem: subsystem, category: "Search")
}
