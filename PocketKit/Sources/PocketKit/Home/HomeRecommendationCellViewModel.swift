// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Combine
import Textile
import CoreData
import Localization

class HomeRecommendationCellViewModel {
    let recommendation: Recommendation
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?

    var isSaved: Bool {
        recommendation.item.savedItem != nil &&
        recommendation.item.savedItem?.isArchived == false
    }

    init(
        recommendation: Recommendation,
        overflowActions: [ItemAction]? = nil,
        primaryAction: ItemAction? = nil
    ) {
        self.recommendation = recommendation
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
    }
}

extension HomeRecommendationCellViewModel: RecommendationCellViewModel {
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
        recommendation.bestTitle
    }

    var imageURL: URL? {
        recommendation.bestImageURL
    }

    var saveButtonMode: RecommendationSaveButton.Mode {
        isSaved ? .saved : .save
    }

    var domain: String? {
        recommendation.bestDomain
    }

    var timeToRead: String? {
        guard let timeToRead = recommendation.item.timeToRead,
              timeToRead.intValue > 0 else {
            return nil
        }

        return Localization.Home.Recommendation.readTime(timeToRead)
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h6.with(color: .ui.black1).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey8).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey8).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
