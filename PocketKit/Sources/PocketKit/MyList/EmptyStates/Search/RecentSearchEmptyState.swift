import Foundation
import Textile

struct RecentSearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchRecent
    let maxWidth: CGFloat = 145
    let icon: ImageAsset? = nil
    let headline = "Recent Searches"
    let detailText: String? = "Your latest searches will appear here so you can get right back to them"
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "recent-search-empty-state"
}
