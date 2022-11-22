import Foundation
import Textile

struct NoResultsEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchNoResults
    let maxWidth: CGFloat = 145
    let icon: ImageAsset? = nil
    let headline = "No Results Found"
    let detailText: String? = "Try using different keywords, checking for typos, or changing your filters."
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "no-results-empty-state"
}
