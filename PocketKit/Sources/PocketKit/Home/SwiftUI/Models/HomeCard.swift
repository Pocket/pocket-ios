// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
@preconcurrency import Sync
import SwiftUI
import Textile

// TODO: SWIFTUI - Add analytics

/// Representation of an `Item` suitable for being displayed in a `Hero` or a `Carousel` card.
@MainActor
struct HomeCard: Identifiable, @preconcurrency Equatable, Hashable {
    static func == (lhs: HomeCard, rhs: HomeCard) -> Bool {
        lhs.givenURL == rhs.givenURL &&
        lhs.imageURL == rhs.imageURL &&
        lhs.sharedWithYouUrlString == rhs.sharedWithYouUrlString
    }

    var id = UUID()
    let givenURL: String
    let imageURL: URL?
    let sharedWithYouUrlString: String?
    let shareURL: String?
    let showExcerpt: Bool

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
        imageURL: URL?,
        sharedWithYouUrlString: String? = nil,
        ShareURL: String? = nil,
        showExcerpt: Bool = false,
        enableSaveAction: Bool = false,
        enableFavoriteAction: Bool = false,
        enableShareMenuAction: Bool = false,
        enableReportMenuAction: Bool = false,
        enableArchiveMenuAction: Bool = false,
        enableDeleteMenuAction: Bool = false
    ) {
        self.givenURL = givenURL
        self.imageURL = imageURL
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.shareURL = ShareURL
        self.showExcerpt = showExcerpt
        self.enableSaveAction = enableSaveAction
        self.enableFavoriteAction = enableFavoriteAction
        self.enableShareMenuAction = enableShareMenuAction
        self.enableReportMenuAction = enableReportMenuAction
        self.enableArchiveMenuAction = enableArchiveMenuAction
        self.enableDeleteMenuAction = enableDeleteMenuAction
    }
}

// MARK: Styler
extension HomeCard {
    var collectionStyle: Style {
        .recommendation.collection
    }

    func titleStyle(largeTitle: Bool) -> Style {
        .recommendation.adaptiveTitle(largeTitle)
    }

    var domainStyle: Style {
        .recommendation.domain
    }

    func timeToRead(_ timeToRead: Int32) -> AttributedString {
        AttributedString(NSAttributedString(string: Localization.Home.Recommendation.readTime(timeToRead), style: .recommendation.timeToRead))
    }
}
