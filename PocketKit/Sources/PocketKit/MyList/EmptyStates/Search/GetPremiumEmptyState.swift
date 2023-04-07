import Foundation
import Textile

// TODO: Localization
struct GetPremiumEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .diamond
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = "Unlock more search options"
    let detailText: String? = "Search your entire Pocket, including archived items, with Pocket Premium."
    let buttonText: String? = "Get Pocket Premium"
    let webURL: URL? = URL(string: "https://getpocket.com/premium")
    let accessibilityIdentifier = "get-premium-empty-state"
}
