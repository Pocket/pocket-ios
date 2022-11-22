import Foundation
import Textile

struct TagsEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = 300
    let icon: ImageAsset? = nil
    let headline = "No saves with this tag."
    let detailText: String? = "Tag your saves by topic to find them later."
    let buttonText: String? = "How to tag"
    let webURL: URL? = URL(string: "https://help.getpocket.com/article/940-tagging-in-pocket-for-iphone")!
    let accessibilityIdentifier = "tags-empty-state"
}
