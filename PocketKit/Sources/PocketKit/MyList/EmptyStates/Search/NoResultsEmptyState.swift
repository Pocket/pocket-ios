// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct NoResultsEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .searchNoResults
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Search.Results.Empty.header
    let detailText: String? = Localization.Search.Results.Empty.detail
    let buttonType: ButtonType? = nil
    let buttonAction: (() -> Void)? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "no-results-empty-state"
}
