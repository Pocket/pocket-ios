import Foundation
import Textile

// TODO: Localization
struct RecentSearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchRecent
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = nil
    let detailText: String? = "Recent searches will appear here, so you can easily jump back in."
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "recent-search-empty-state"
}
