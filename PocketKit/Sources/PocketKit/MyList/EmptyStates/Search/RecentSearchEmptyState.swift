// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct RecentSearchEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchRecent
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = nil
    let detailText: String? = Localization.Search.Recent.empty
    let buttonType: ButtonType? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "recent-search-empty-state"
}
