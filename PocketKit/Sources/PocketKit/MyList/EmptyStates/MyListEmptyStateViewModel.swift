import Foundation
import Textile


struct MyListEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .welcomeShelf
    let icon: ImageAsset? = nil
    let headline = "Start building your Pocket list"
    let detailText: String? = nil
    let buttonText: String? = "How to save"
    let webURL: URL? = URL(string: "https://getpocket.com/saving-in-ios")!
    let accessibilityIdentifier = "my-list-empty-state"
}
