// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Textile
import Localization
import SharedPocketKit

struct RecentSavesCellConfiguration: HomeCarouselCellConfiguration {
    let item: ItemsListItem
    let favoriteAction: ItemAction?
    let overflowActions: [ItemAction]?
    let thumbnailURL: URL?

    // Unused properties for recent saves cells
    let saveButtonMode: ItemCellSaveButton.Mode? = nil
    let saveAction: ItemAction? = nil

    init(
        item: ItemsListItem,
        favoriteAction: ItemAction?,
        overflowActions: [ItemAction]?
    ) {
        self.item = item
        self.favoriteAction = favoriteAction
        self.overflowActions = overflowActions
        self.thumbnailURL = CDNURLBuilder().imageCacheURL(for: item.topImageURL)
    }

    var attributedCollection: NSAttributedString? {
        guard item.isCollection else { return nil }
        return NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: .recommendation.title)
    }

    var attributedDomain: NSAttributedString {
        let detailString = NSMutableAttributedString(string: domain ?? "", style: .recommendation.domain)
        return item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString
    }

    var attributedTimeToRead: NSAttributedString {
        return NSAttributedString(string: timeToRead ?? "", style: .recommendation.timeToRead)
    }

    var sharedWithYouUrlString: String? {
        nil
    }

    private var domain: String? {
        item.displayDomain
    }

    private var title: String {
        item.displayTitle
    }

    private var timeToRead: String? {
        guard let timeToRead = item.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return Localization.minRead(timeToRead)
    }
}
