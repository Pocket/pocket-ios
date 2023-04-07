import Foundation
import Textile
import SharedPocketKit

// TODO: Localization
struct OfflineEmptyState: EmptyStateViewModel {
    private let type: SearchScope

    init(type: SearchScope) {
        self.type = type
    }

    let imageAsset: ImageAsset = .looking
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = "No Internet Connection"
    var detailText: String? {
        let searchScopeText = type == .archive ? "archived" : "all"
        return "You must be online to search \(searchScopeText) items."
    }
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "offline-empty-state"
}
