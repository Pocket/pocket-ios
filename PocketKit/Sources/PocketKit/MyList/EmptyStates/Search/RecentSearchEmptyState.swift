import Foundation
import Textile
import Localization

struct RecentSearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchRecent
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = nil
    let detailText: String? = Localization.Search.Recent.empty
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "recent-search-empty-state"
}
