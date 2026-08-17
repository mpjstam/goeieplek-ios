import Foundation

enum NavigationDestination: Hashable {
  case collection(Collection)
  case place(Place)

  func hash(into hasher: inout Hasher) {
    switch self {
    case .collection(let collection):
      hasher.combine(0)
      hasher.combine(collection.id)
    case .place(let place):
      hasher.combine(1)
      hasher.combine(place.id)
    }
  }

  static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
    switch (lhs, rhs) {
    case (.collection(let a), .collection(let b)):
      return a.id == b.id
    case (.place(let a), .place(let b)):
      return a.id == b.id
    default:
      return false
    }
  }
}
