import Foundation
import Textile
import Localization

struct NoResultsEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchNoResults
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Search.Results.Empty.header
    let detailText: String? = Localization.Search.Results.Empty.detail
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "no-results-empty-state"
}
