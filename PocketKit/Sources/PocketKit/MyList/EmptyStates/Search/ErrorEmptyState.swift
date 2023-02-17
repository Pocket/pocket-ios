// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile

struct ErrorEmptyState: EmptyStateViewModel {
    let imageAsset: ImageAsset = .warning
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = L10n.Search.errorHeadline
    let detailText: String? = L10n.Search.errorMessage
    let buttonText: String? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "error-empty-state"
}
