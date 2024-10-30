// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
@preconcurrency import Sync
import SwiftUI
import Textile

/// Card configuration
@MainActor
struct HomeCardConfiguration: Identifiable, @preconcurrency Equatable, Hashable {
    static func == (lhs: HomeCardConfiguration, rhs: HomeCardConfiguration) -> Bool {
        lhs.givenURL == rhs.givenURL &&
        lhs.sharedWithYouUrlString == rhs.sharedWithYouUrlString
    }

    var id = UUID()
    let givenURL: String
    let sharedWithYouUrlString: String?
    let showExcerpt: Bool
    let type: CardType

    // actions configuration
    let enableSaveAction: Bool
    let enableFavoriteAction: Bool
    // menu actions configuration
    let enableShareMenuAction: Bool
    let enableReportMenuAction: Bool
    let enableArchiveMenuAction: Bool
    let enableDeleteMenuAction: Bool

    init(
        givenURL: String,
        sharedWithYouUrlString: String? = nil,
        showExcerpt: Bool = false,
        type: CardType,
        enableSaveAction: Bool = false,
        enableFavoriteAction: Bool = false,
        enableShareMenuAction: Bool = false,
        enableReportMenuAction: Bool = false,
        enableArchiveMenuAction: Bool = false,
        enableDeleteMenuAction: Bool = false
    ) {
        self.givenURL = givenURL
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.showExcerpt = showExcerpt
        self.type = type
        self.enableSaveAction = enableSaveAction
        self.enableFavoriteAction = enableFavoriteAction
        self.enableShareMenuAction = enableShareMenuAction
        self.enableReportMenuAction = enableReportMenuAction
        self.enableArchiveMenuAction = enableArchiveMenuAction
        self.enableDeleteMenuAction = enableDeleteMenuAction
    }
}
