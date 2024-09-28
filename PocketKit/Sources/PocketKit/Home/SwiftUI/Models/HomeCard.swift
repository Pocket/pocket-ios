// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Sync
import SwiftUI
import Textile

// TODO: SWIFTUI - Add analytics

/// Representation of an `Item` suitable for being displayed in a `Hero` or a `Carousel` card.
@MainActor
struct HomeCard: Identifiable, @preconcurrency Equatable {
    static func == (lhs: HomeCard, rhs: HomeCard) -> Bool {
        lhs.givenURL == rhs.givenURL &&
        lhs.imageURL == rhs.imageURL &&
        lhs.sharedWithYouUrlString == rhs.sharedWithYouUrlString
    }

    var id = UUID()
    let givenURL: String
    let overflowActions: [HomeButtonAction]
    let favoriteAction: HomeButtonAction?
    var imageURL: URL?
    var sharedWithYouUrlString: String?
    let useLargeTitle: Bool

    // actions configuration
    let enableSaveAction: Bool
    let enableFavoriteAction: Bool

    init(
        givenURL: String,
        overflowActions: [HomeButtonAction] = [],
        favoriteAction: HomeButtonAction? = nil,
        imageURL: URL?,
        sharedWithYouUrlString: String? = nil,
        uselargeTitle: Bool = false,
        enableSaveAction: Bool = false,
        enableFavoriteAction: Bool = false
    ) {
        self.givenURL = givenURL
        self.overflowActions = overflowActions
        self.favoriteAction = favoriteAction
        self.imageURL = imageURL
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.useLargeTitle = uselargeTitle
        self.enableSaveAction = enableSaveAction
        self.enableFavoriteAction = enableFavoriteAction
    }
}

// MARK: Actions
extension HomeCard {
    func saveAction(isSaved: Bool) {
        // TODO: SWIFTUI - Once we are fully migrated to SwiftUI, this should come from the environment.
        let source = Services.shared.source
        if isSaved {
            source.archive(from: givenURL)
        } else {
            source.save(from: givenURL)
        }
    }

    func favoriteAction(isFavorite: Bool, givenURL: String) {
        // TODO: SWIFTUI - Once we are fully migrated to SwiftUI, this should come from the environment.
        let source = Services.shared.source
        if isFavorite {
            source.unFavorite(givenURL)
        } else {
            source.favorite(givenURL)
        }
    }
}

// MARK: Styler
extension HomeCard {
    var collectionStyle: Style {
        .recommendation.collection
    }

    // TODO: SWIFTUI - use the proper style here once we do native collections
    var attributedExcerpt: AttributedString? {
        return nil
    }

    var titleStyle: Style {
        .recommendation.adaptiveTitle(useLargeTitle)
    }

    var domainStyle: Style {
        .recommendation.domain
    }

    func timeToRead(_ timeToRead: Int32) -> AttributedString {
        AttributedString(NSAttributedString(string: Localization.Home.Recommendation.readTime(timeToRead), style: .recommendation.timeToRead))
    }
}
