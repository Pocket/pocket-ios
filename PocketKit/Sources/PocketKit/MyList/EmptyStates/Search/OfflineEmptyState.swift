import Foundation
import Textile

struct OfflineEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .looking
    let maxWidth: CGFloat = 300
    let icon: ImageAsset? = nil
    let headline = "No Internet Connection"
    let detailText: String? = "You must be online to search."
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "offline-empty-state"
}
