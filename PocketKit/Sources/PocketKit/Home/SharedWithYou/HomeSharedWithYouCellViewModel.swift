// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Combine
import Textile
import CoreData
import Localization

class HomeSharedWithYouCellViewModel {
    let sharedWithYou: SharedWithYouHighlight
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?

    var isSaved: Bool {
        sharedWithYou.item.savedItem != nil &&
        sharedWithYou.item.savedItem?.isArchived == false
    }

    init(
        sharedWithYou: SharedWithYouHighlight,
        overflowActions: [ItemAction]? = nil,
        primaryAction: ItemAction? = nil
    ) {
        self.sharedWithYou = sharedWithYou
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
    }
}

extension HomeSharedWithYouCellViewModel: HomeCarouselItemCellModel {
    var attributedCollection: NSAttributedString? {
        return nil
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title ?? "", style: .title)
    }

    var attributedDomain: NSAttributedString {
        NSAttributedString(string: domain ?? "", style: .domain)
    }

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
    }

    var title: String? {
        sharedWithYou.bestTitle ?? ""
    }

    var saveButtonMode: RecommendationSaveButton.Mode? {
        isSaved ? .saved : .save
    }

    var domain: String? {
        sharedWithYou.bestDomain
    }

    var timeToRead: String? {
        guard let timeToRead = sharedWithYou.item.timeToRead,
              timeToRead.intValue > 0 else {
            return nil
        }

        return Localization.Home.Recommendation.readTime(timeToRead)
    }

    var thumbnailURL: URL? {
        sharedWithYou.bestImageURL
    }

    var favoriteAction: ItemAction? {
        return nil
    }

    var saveAction: ItemAction? {
        self.primaryAction
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h6.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
