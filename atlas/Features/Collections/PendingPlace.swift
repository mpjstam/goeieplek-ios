import Foundation

struct PendingPlace: Identifiable, Equatable {
  let id = UUID()
  let name: String
  let latitude: Double
  let longitude: Double
}
