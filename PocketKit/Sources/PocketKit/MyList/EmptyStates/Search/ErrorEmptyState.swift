// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct ErrorEmptyState: EmptyStateViewModel {
    private var featureFlags: FeatureFlagServiceProtocol

    init(featureFlags: FeatureFlagServiceProtocol) {
        self.featureFlags = featureFlags
    }

    let imageAsset: ImageAsset = .warning
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.General.oops
    let detailText: String? = Localization.Search.errorMessage
    let webURL: URL? = nil
    let accessibilityIdentifier = "error-empty-state"

    var buttonType: ButtonType? {
        if featureFlags.isAssigned(flag: .reportIssue) {
            return .reportIssue(Localization.General.Error.sendReport)
        }
        return nil
    }
}
