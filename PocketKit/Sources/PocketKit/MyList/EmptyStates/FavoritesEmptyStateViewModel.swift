import Foundation
import Textile

struct FavoritesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = 300
    let icon: ImageAsset? = .favorite
    let headline = "Find your favorites here"
    let detailText: String? = "Hit the star icon to favorite an article and find it faster."
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "favorites-empty-state"
}
