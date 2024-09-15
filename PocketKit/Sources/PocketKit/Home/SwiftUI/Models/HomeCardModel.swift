// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Sync
import SwiftUI

// TODO: SWIFTUI - Add analytics

@MainActor
@Observable
final class HomeCardModel {
    let item: Item
    let overflowActions: [HomeButtonAction]
    let favoriteAction: HomeButtonAction?
    var imageURL: URL?
    var title: String?
    var sharedWithYouUrlString: String?
    let useLargeTitle: Bool
    // TODO: SWIFTUI - Once we are fully migrated to SwiftUI, this should come from the environment.
    private let source = Services.shared.source

    init(
        item: Item,
        overflowActions: [HomeButtonAction] = [],
        favoriteAction: HomeButtonAction? = nil,
        imageURL: URL?,
        title: String? = nil,
        sharedWithYouUrlString: String? = nil,
        uselargeTitle: Bool = false
    ) {
        self.item = item
        self.overflowActions = overflowActions
        self.favoriteAction = favoriteAction
        self.imageURL = imageURL
        self.title = title ?? item.syndicatedArticle?.title ?? item.title
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.useLargeTitle = uselargeTitle
    }

    func saveAction(isSaved: Bool) {
        if isSaved {
            source.archive(from: item.givenURL)
        } else {
            source.save(from: item.givenURL)
        }
    }
}

extension HomeCardModel {
    var attributedCollection: AttributedString? {
        guard item.isCollection else { return nil }
        return AttributedString(NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection))
    }

    var attributedTitle: AttributedString {
        AttributedString(NSAttributedString(string: title ?? "", style: .recommendation.adaptiveTitle(useLargeTitle)))
    }

    var attributedExcerpt: AttributedString? {
        return nil
    }

    var attributedDomain: AttributedString? {
        guard let domain else { return nil }
        let detailString = NSMutableAttributedString(string: domain, style: .recommendation.domain)
        return AttributedString(item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString)
    }

    var attributedTimeToRead: AttributedString? {
        guard let timeToRead else { return nil }
        return AttributedString(NSAttributedString(string: timeToRead, style: .recommendation.timeToRead))
    }

    private var domain: String? {
        item.bestDomain
    }

    private var timeToRead: String? {
        guard let timeToRead = item.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return Localization.Home.Recommendation.readTime(timeToRead)
    }
}
