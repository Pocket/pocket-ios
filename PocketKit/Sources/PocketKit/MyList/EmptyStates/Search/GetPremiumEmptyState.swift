import Foundation
import Textile

// TODO: Localization
struct GetPremiumEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .diamond
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline = "Searching in All Your Items?"
    let detailText: String? = "See results from both saves and archive when you join Pocket Premium."
    let buttonText: String? = "Get Pocket Premium"
    let webURL: URL? = URL(string: "https://getpocket.com/premium")
    let accessibilityIdentifier = "get-premium-empty-state"
}
