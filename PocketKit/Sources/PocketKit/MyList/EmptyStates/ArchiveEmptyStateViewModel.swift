import Foundation
import Textile

struct ArchiveEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = 300
    let icon: ImageAsset? = .archive
    let headline = "Keep your list fresh and clean"
    let detailText: String? = "Archive the saves you're finished with\n using the archive icon."
    let buttonText: String? = "How to archive"
    let webURL: URL? = URL(string: "https://getpocket.com/what-is-the-archive-ios")!
    let accessibilityIdentifier = "archive-empty-state"
}
