import Foundation
import Textile
import SharedPocketKit
import Localization

struct OfflineEmptyState: EmptyStateViewModel {
    private let type: SearchScope

    init(type: SearchScope) {
        self.type = type
    }

    let imageAsset: ImageAsset = .looking
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Search.Results.Offline.header
    var detailText: String? {
        let localizationDetail = Localization.Search.Results.Offline.Detail.self
        let searchScopeText = type == .archive ? localizationDetail.archive : localizationDetail.all

        return Localization.Search.Results.Offline.detail(searchScopeText)
    }
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "offline-empty-state"
}
