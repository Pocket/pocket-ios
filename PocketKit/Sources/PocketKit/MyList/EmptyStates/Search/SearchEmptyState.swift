import Foundation
import Textile

// TODO: Localization
struct SearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .search
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = "Search by title or URL"
    let detailText: String? = nil
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "search-empty-state"
}
