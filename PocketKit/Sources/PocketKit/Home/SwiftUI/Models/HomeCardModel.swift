// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Sync
import SwiftUI
import Textile

// TODO: SWIFTUI - Add analytics

/// Type that holds the configuration of `Hero` and `Carousel` cards
@MainActor
struct HomeCardModel {
    let givenURL: String
    let overflowActions: [HomeButtonAction]
    let favoriteAction: HomeButtonAction?
    var imageURL: URL?
    var sharedWithYouUrlString: String?
    let useLargeTitle: Bool
    // TODO: SWIFTUI - Once we are fully migrated to SwiftUI, this should come from the environment.
    private let source = Services.shared.source

    init(
        givenURL: String,
        overflowActions: [HomeButtonAction] = [],
        favoriteAction: HomeButtonAction? = nil,
        imageURL: URL?,
        sharedWithYouUrlString: String? = nil,
        uselargeTitle: Bool = false
    ) {
        self.givenURL = givenURL
        self.overflowActions = overflowActions
        self.favoriteAction = favoriteAction
        self.imageURL = imageURL
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.useLargeTitle = uselargeTitle
    }
}

// MARK: Actions
extension HomeCardModel {
    func saveAction(isSaved: Bool) {
        if isSaved {
            source.archive(from: givenURL)
        } else {
            source.save(from: givenURL)
        }
    }
}

// MARK: Styler
extension HomeCardModel {
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
