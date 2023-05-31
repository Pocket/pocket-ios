// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Localization

struct SavesEmptyStateViewModel: EmptyStateViewModel {
    let imageAsset: ImageAsset = .welcomeShelf
    let maxWidth: CGFloat = Width.wide.rawValue
    let icon: ImageAsset? = nil
    let headline: String? = Localization.Saves.Empty.header
    let detailText: String? = nil
    let buttonType: ButtonType? = .normal(Localization.Saves.Empty.button)
    let webURL: URL? = URL(string: "https://getpocket.com/saving-in-ios")!
    let accessibilityIdentifier = "saves-empty-state"
}
