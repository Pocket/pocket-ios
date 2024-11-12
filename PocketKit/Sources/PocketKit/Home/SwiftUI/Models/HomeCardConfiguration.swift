// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
@preconcurrency import Sync
import SwiftUI
import Textile

/// Card configuration
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
    let index: Int

    let shareURL: String?
    let domain: String?
    let timeToRead: Int32?
    let isSyndicated: Bool
    let recommendationID: String?
    let bestTitle: String?
    let slug: String?
    let excerpt: String?
    let topImageURL: URL?

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
        index: Int,
        shareURL: String?,
        domain: String?,
        timeToRead: Int32?,
        isSyndicated: Bool,
        recommendationID: String?,
        bestTitle: String?,
        slug: String?,
        excerpt: String?,
        topImageURL: URL?,
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
        self.index = index
        self.shareURL = shareURL
        self.domain = domain
        self.timeToRead = timeToRead
        self.isSyndicated = isSyndicated
        self.recommendationID = recommendationID
        self.bestTitle = bestTitle
        self.slug = slug
        self.excerpt = excerpt
        self.topImageURL = topImageURL
        self.enableSaveAction = enableSaveAction
        self.enableFavoriteAction = enableFavoriteAction
        self.enableShareMenuAction = enableShareMenuAction
        self.enableReportMenuAction = enableReportMenuAction
        self.enableArchiveMenuAction = enableArchiveMenuAction
        self.enableDeleteMenuAction = enableDeleteMenuAction
    }
}
