// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization
import SharedPocketKit

struct ErrorEmptyState: EmptyStateViewModel {
    private var featureFlags: FeatureFlagServiceProtocol
    private var user: User

    init(featureFlags: FeatureFlagServiceProtocol, user: User) {
        self.featureFlags = featureFlags
        self.user = user
    }

    let imageAsset: ImageAsset = .warning
    let maxWidth: CGFloat = Width.normal.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.General.oops
    let detailText: String? = Localization.Search.errorMessage
    let webURL: URL? = nil
    let accessibilityIdentifier = "error-empty-state"
    let buttonAction: (() -> Void)? = nil

    var buttonType: ButtonType? {
        if featureFlags.isAssigned(flag: .reportIssue) {
            return .reportIssue(text: Localization.General.Error.sendReport, email: user.email)
        }
        return nil
    }
}
