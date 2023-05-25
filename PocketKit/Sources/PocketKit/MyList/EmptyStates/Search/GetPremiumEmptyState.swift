// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct GetPremiumEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .diamond
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Search.AllItems.Premium.header
    let detailText: String? = Localization.Search.AllItems.Premium.detail
    let buttonType: ButtonType? = .premium(Localization.Search.AllItems.Premium.button)
    let webURL: URL? = URL(string: "https://getpocket.com/premium")
    let accessibilityIdentifier = "get-premium-empty-state"
}
