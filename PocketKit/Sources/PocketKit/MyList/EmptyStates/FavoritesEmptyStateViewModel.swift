import Foundation
import Textile
import Localization

struct FavoritesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = .favorite
    let headline: String? = Localization.Favourites.Empty.header
    let detailText: String? = Localization.Favourites.Empty.detail
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "favorites-empty-state"
}
