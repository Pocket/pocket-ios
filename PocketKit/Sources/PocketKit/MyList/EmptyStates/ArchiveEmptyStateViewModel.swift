import Foundation
import Textile
import Localization

struct ArchiveEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = .archive
    let headline: String? = Localization.Archive.Empty.header
    let detailText: String? = Localization.Archive.Empty.detail
    let buttonType: ButtonType? = .normal(Localization.Archive.Empty.button)
    let webURL: URL? = URL(string: "https://getpocket.com/what-is-the-archive-ios")!
    let accessibilityIdentifier = "archive-empty-state"
}
