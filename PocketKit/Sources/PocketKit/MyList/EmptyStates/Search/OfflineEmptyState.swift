// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
        let detail = Localization.Search.Results.Offline.Detail.self

        if type == .all {
            return detail.all
        } else {
            return detail.archive
        }
    }
    let buttonType: ButtonType? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "offline-empty-state"
}
