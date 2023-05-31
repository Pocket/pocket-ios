// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct TagsEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Tags.Empty.header
    let detailText: String? =  Localization.Tags.Empty.detail
    let buttonType: ButtonType? = .normal(Localization.Tags.Empty.button)
    let webURL: URL? = URL(string: "https://help.getpocket.com/article/940-tagging-in-pocket-for-iphone")!
    let accessibilityIdentifier = "tags-empty-state"
}
