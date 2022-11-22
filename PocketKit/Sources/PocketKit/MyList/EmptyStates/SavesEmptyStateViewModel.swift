import Foundation
import Textile

struct SavesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .welcomeShelf
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline = "Start building your Pocket list"
    let detailText: String? = nil
    let buttonText: String? = "How to save"
    let webURL: URL? = URL(string: "https://getpocket.com/saving-in-ios")!
    let accessibilityIdentifier = "saves-empty-state"
}
