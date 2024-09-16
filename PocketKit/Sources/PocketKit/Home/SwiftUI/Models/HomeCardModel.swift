// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Sync
import SwiftUI

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

    func saveAction(isSaved: Bool) {
        if isSaved {
            source.archive(from: givenURL)
        } else {
            source.save(from: givenURL)
        }
    }
}

extension HomeCardModel {
    var attributedCollection: AttributedString {
        return AttributedString(NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection))
    }

    var attributedExcerpt: AttributedString? {
        return nil
    }

    func attributedTitle(_ title: String) -> AttributedString {
        AttributedString(NSAttributedString(string: title, style: .recommendation.adaptiveTitle(useLargeTitle)))
    }

    func attributedDomain(_ domain: String, isSyndicated: Bool) -> AttributedString {
        let detailString = NSMutableAttributedString(string: domain, style: .recommendation.domain)
        return AttributedString(isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString)
    }

    func timeToRead(_ timeToRead: Int32) -> AttributedString {
        AttributedString(NSAttributedString(string: Localization.Home.Recommendation.readTime(timeToRead), style: .recommendation.timeToRead))
    }
}
