// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Combine
import Textile
import CoreData
import Localization

/// View model for Item cells in unified Home
class HomeItemCellViewModel {
    let item: Item
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?
    var imageURL: URL?
    var title: String?

    var isSaved: Bool {
        item.savedItem != nil &&
        item.savedItem?.isArchived == false
    }

    init(
        item: Item,
        overflowActions: [ItemAction]? = nil,
        primaryAction: ItemAction? = nil,
        imageURL: URL?,
        title: String? = nil
    ) {
        self.item = item
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
        self.imageURL = imageURL
        self.title = title ?? item.syndicatedArticle?.title ?? item.title
    }
}

extension HomeItemCellViewModel: ItemCellViewModel {
    var attributedCollection: NSAttributedString? {
        guard item.isCollection else { return nil }
        return NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title ?? "", style: .recommendation.heroTitle)
    }

    var attributedExcerpt: NSAttributedString? {
        return nil
    }

    var attributedDomain: NSAttributedString {
        let detailString = NSMutableAttributedString(string: domain ?? "", style: .recommendation.domain)
        return item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString
    }

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .recommendation.timeToRead)
    }

    var saveButtonMode: ItemCellSaveButton.Mode {
        isSaved ? .saved : .save
    }

    var domain: String? {
        item.bestDomain
    }

    var timeToRead: String? {
        guard let timeToRead = item.timeToRead,
              timeToRead.intValue > 0 else {
            return nil
        }

        return Localization.Home.Recommendation.readTime(timeToRead)
    }
}
