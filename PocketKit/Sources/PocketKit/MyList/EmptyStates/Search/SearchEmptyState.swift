import Foundation
import Textile

struct SearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .search
    let maxWidth: CGFloat = 145
    let icon: ImageAsset? = nil
    let headline = "Search by Title or URL"
    let detailText: String? = nil
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "search-empty-state"
}
