import UIKit
import UniformTypeIdentifiers

/// The share sheet entry point when sharing a place from Apple Maps, Google
/// Maps, or any other app, into Atlas. Does no link parsing itself — it
/// extracts whatever URL or text was shared and drops it in the App Group.
/// All the actual link resolution stays in the main app target, dispatched
/// through `MapsLinkImport`.
///
/// Saves quietly and returns you to the host app — it does not, and cannot,
/// switch to Atlas itself. `NSExtensionContext.open(_:completionHandler:)`
/// reliably returns `success: false` for share extensions specifically, even
/// when called synchronously from inside a real button tap (confirmed with a
/// device console log, ruling out the interaction-timing theory this used to
/// carry). Atlas picks the share up itself instead, via `RootView` checking
/// for a pending one on every foreground transition, and surfaces it as a
/// standing banner on the Search tab — see `SearchTabView.incomingShareBanner`.
///
/// A plain `UIViewController` rather than `SLComposeServiceViewController` — the
/// composer's "type a caption, tap Post" flow doesn't fit "save this location",
/// and this needs no caption at all.
final class ShareViewController: UIViewController {
  private let appGroupID = "group.studiostam.atlas"
  private let pendingDirectoryName = "PendingMapsShares"

  private let spinner = UIActivityIndicatorView(style: .medium)
  private let statusLabel = UILabel()
  private var hasStartedProcessing = false

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !hasStartedProcessing else { return }
    hasStartedProcessing = true
    processShare()
  }

  private func setUpUI() {
    view.backgroundColor = .systemBackground
    preferredContentSize = CGSize(width: 280, height: 150)

    spinner.startAnimating()

    statusLabel.text = "Opslaan in Goeieplek…"
    statusLabel.font = .preferredFont(forTextStyle: .body)
    statusLabel.textColor = .label
    statusLabel.textAlignment = .center
    statusLabel.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [spinner, statusLabel])
    stack.axis = .vertical
    stack.spacing = 16
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
    ])
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }

  private func processShare() {
    print("[AtlasShare] processShare started")
    extractSharedText { [weak self] shared in
      DispatchQueue.main.async {
        guard let self else { return }
        print("[AtlasShare] extracted shared text: \(shared ?? "nil")")
        guard let shared else {
          self.finish(showing: "Kon die link niet lezen.")
          return
        }
        let outcome = self.persist(shared)
        print("[AtlasShare] persist outcome: \(outcome)")
        switch outcome {
        case .success:
          self.finish(showing: "Opgeslagen in Goeieplek")
        case .containerUnavailable:
          // `containerURL(forSecurityApplicationGroupIdentifier:)` returned nil —
          // the App Group entitlement itself isn't being granted to this process,
          // regardless of which API is used to write into it. Say so plainly rather
          // than silently completing as if it worked.
          self.finish(showing: "Kon de gedeelde opslag van Goeieplek niet bereiken.\n(App Group niet beschikbaar)")
        case .writeFailed:
          self.finish(showing: "Kon die link niet opslaan.")
        }
      }
    }
  }

  private func finish(showing message: String) {
    spinner.stopAnimating()
    spinner.isHidden = true
    statusLabel.text = message
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
      self?.finish()
    }
  }

  private enum PersistResult {
    case success
    case containerUnavailable
    case writeFailed
  }

  /// Writes each share as its own file in a shared-container subdirectory,
  /// rather than one fixed file — sharing several locations in a row (before
  /// ever opening Atlas) must queue them all, not have each one silently
  /// overwrite the last. The timestamp-prefixed filename keeps `MapsShareInbox`
  /// able to recover share order without any extra bookkeeping file.
  ///
  /// Writes directly to disk rather than going through `UserDefaults`/`CFPreferences`
  /// — `FileManager.write(to:atomically:)` is a plain, synchronous disk write with no
  /// daemon-mediated caching layer in between, and `containerURL(forSecurityApplicationGroupIdentifier:)`
  /// returning nil is the direct, unambiguous signal that the App Group entitlement
  /// isn't actually being granted to this process.
  private func persist(_ value: String) -> PersistResult {
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      print("[AtlasShare] containerURL(forSecurityApplicationGroupIdentifier: \"\(appGroupID)\") returned nil")
      return .containerUnavailable
    }
    let directoryURL = containerURL.appendingPathComponent(pendingDirectoryName, isDirectory: true)
    let fileName = "\(Date().timeIntervalSince1970)-\(UUID().uuidString).txt"
    let fileURL = directoryURL.appendingPathComponent(fileName)
    print("[AtlasShare] container found, writing to: \(fileURL.path)")
    do {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      try value.write(to: fileURL, atomically: true, encoding: .utf8)
      print("[AtlasShare] write succeeded")
      return .success
    } catch {
      print("[AtlasShare] write threw: \(error)")
      return .writeFailed
    }
  }

  /// Checks every plausible source of the shared text rather than assuming it's a
  /// well-formed attachment. Observed on-device: Google Maps' share item declares a
  /// `public.plain-text` attachment that loads successfully but is a literal empty
  /// string — the real link lives on `NSExtensionItem.attributedContentText`
  /// instead, a separate slot several apps use for the shareable text alongside (or
  /// instead of) a formal attachment. Checks that first, across every input item,
  /// before falling back to walking every attachment's declared type identifiers.
  private func extractSharedText(completion: @escaping (String?) -> Void) {
    guard let items = extensionContext?.inputItems as? [NSExtensionItem], !items.isEmpty else {
      print("[AtlasShare] no NSExtensionItems in inputItems")
      completion(nil)
      return
    }
    for (index, item) in items.enumerated() {
      print("""
        [AtlasShare] item \(index): \
        contentText=\(item.attributedContentText?.string ?? "nil") \
        title=\(item.attributedTitle?.string ?? "nil") \
        attachments=\(item.attachments?.count ?? 0)
        """)
    }

    for item in items {
      if let text = item.attributedContentText?.string, !text.isEmpty {
        print("[AtlasShare] using attributedContentText")
        completion(text)
        return
      }
    }

    let providers = items.flatMap { $0.attachments ?? [] }
    guard !providers.isEmpty else {
      print("[AtlasShare] no attachments across \(items.count) item(s)")
      completion(nil)
      return
    }
    loadFirstNonEmptyValue(fromProviders: providers, completion: completion)
  }

  private func loadFirstNonEmptyValue(
    fromProviders providers: [NSItemProvider],
    providerIndex: Int = 0,
    completion: @escaping (String?) -> Void
  ) {
    guard providerIndex < providers.count else {
      completion(nil)
      return
    }
    let provider = providers[providerIndex]
    print("[AtlasShare] provider \(providerIndex) registeredTypeIdentifiers: \(provider.registeredTypeIdentifiers)")
    loadFirstNonEmptyValue(from: provider, typeIdentifiers: provider.registeredTypeIdentifiers) { [weak self] value in
      if let value, !value.isEmpty {
        completion(value)
      } else {
        self?.loadFirstNonEmptyValue(fromProviders: providers, providerIndex: providerIndex + 1, completion: completion)
      }
    }
  }

  private func loadFirstNonEmptyValue(
    from provider: NSItemProvider,
    typeIdentifiers: [String],
    index: Int = 0,
    completion: @escaping (String?) -> Void
  ) {
    guard index < typeIdentifiers.count else {
      completion(nil)
      return
    }
    let typeIdentifier = typeIdentifiers[index]
    provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] loaded, error in
      let value = Self.string(from: loaded)
      print("[AtlasShare] loaded \(typeIdentifier) -> \(String(describing: loaded.map { type(of: $0) })) value=\(value ?? "nil") error=\(String(describing: error))")
      if let value, !value.isEmpty {
        completion(value)
      } else {
        self?.loadFirstNonEmptyValue(from: provider, typeIdentifiers: typeIdentifiers, index: index + 1, completion: completion)
      }
    }
  }

  private static func string(from loaded: NSSecureCoding?) -> String? {
    switch loaded {
    case let url as URL: url.absoluteString
    case let string as String: string
    case let nsString as NSString: nsString as String
    default: nil
    }
  }
}
