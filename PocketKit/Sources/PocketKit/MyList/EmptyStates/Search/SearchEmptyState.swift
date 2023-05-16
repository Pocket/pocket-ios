import Foundation
import Textile
import Localization

struct SearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .search
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Search.Empty.header
    let detailText: String? = nil
    let buttonType: ButtonType? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "search-empty-state"
}
