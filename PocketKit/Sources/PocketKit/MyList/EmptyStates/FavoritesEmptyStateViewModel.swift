// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct FavoritesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .chest
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = .favorite
    let headline: String? = Localization.Favourites.Empty.header
    let detailText: String? = Localization.Favourites.Empty.detail
    let buttonType: ButtonType? = nil
    let webURL: URL? = nil
    let accessibilityIdentifier = "favorites-empty-state"
}
