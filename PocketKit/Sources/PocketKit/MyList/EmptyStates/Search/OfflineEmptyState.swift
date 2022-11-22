import Foundation
import Textile

// TODO: Localization
struct OfflineEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .looking
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline = "No Internet Connection"
    let detailText: String? = "You must be online to search."
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "offline-empty-state"
}
