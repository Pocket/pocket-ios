import Foundation
import Textile
import Localization

struct SavesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .welcomeShelf
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Saves.Empty.header
    let detailText: String? = nil
    let buttonType: ButtonType? = .normal(Localization.Saves.Empty.button)
    let webURL: URL? = URL(string: "https://getpocket.com/saving-in-ios")!
    let accessibilityIdentifier = "saves-empty-state"
}
