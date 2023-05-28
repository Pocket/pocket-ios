// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Textile
import Localization
import SharedPocketKit

class RecentSavesItemCell: HomeCarouselItemCell {
    struct Model: HomeCarouselItemCellModel {
        let item: ItemsListItem
        let favoriteAction: ItemAction?
        let overflowActions: [ItemAction]?
        let thumbnailURL: URL?

        // Unused properties for recent saves cells
        let saveButtonMode: RecommendationSaveButton.Mode? = nil
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

        var attributedTitle: NSAttributedString {
            NSAttributedString(string: title, style: .title)
        }

        var attributedDomain: NSAttributedString {
            return NSAttributedString(string: domain ?? "", style: .domain)
        }

        var attributedTimeToRead: NSAttributedString {
            return NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
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
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with(color: .ui.black1).with { paragraph in
        paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey8).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey8).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
