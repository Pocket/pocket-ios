// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Sync
import SwiftUI

@Observable
final class HomeCardModel {
    let item: Item
    let overflowActions: [HomeButtonAction]
    let primaryAction: HomeButtonAction?
    let favoriteAction: HomeButtonAction?
    var imageURL: URL?
    var title: String?
    var sharedWithYouUrlString: String?

    var isSaved: Bool {
        item.savedItem != nil &&
        item.savedItem?.isArchived == false
    }

    init(
        item: Item,
        overflowActions: [HomeButtonAction] = [],
        primaryAction: HomeButtonAction? = nil,
        favoriteAction: HomeButtonAction? = nil,
        imageURL: URL?,
        title: String? = nil,
        sharedWithYouUrlString: String? = nil
    ) {
        self.item = item
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
        self.favoriteAction = favoriteAction
        self.imageURL = imageURL
        self.title = title ?? item.syndicatedArticle?.title ?? item.title
        self.sharedWithYouUrlString = sharedWithYouUrlString
    }
}

extension HomeCardModel {
    var attributedCollection: AttributedString? {
        guard item.isCollection else { return nil }
        return AttributedString(NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection))
    }

    var attributedTitle: AttributedString {
        AttributedString(NSAttributedString(string: title ?? "", style: .recommendation.heroTitle))
    }

    var attributedExcerpt: AttributedString? {
        return nil
    }

    var attributedDomain: AttributedString {
        let detailString = NSMutableAttributedString(string: domain ?? "", style: .recommendation.domain)
        return AttributedString(item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString)
    }

    var attributedTimeToRead: AttributedString {
        AttributedString(NSAttributedString(string: timeToRead ?? "", style: .recommendation.timeToRead))
    }

    var saveButtonMode: ItemCellSaveButton.Mode {
        isSaved ? .saved : .save
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