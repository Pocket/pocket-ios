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
    var attributedCollection: NSAttributedString? {
        guard recommendation.item.isCollection else { return nil }
        return NSAttributedString(string: Localization.Collection.title, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title ?? "", style: .recommendation.heroTitle)
    }

    var attributedExcerpt: NSAttributedString? {
        return nil
    }

    var attributedDomain: NSAttributedString {
        let detailString = NSMutableAttributedString(string: domain ?? "", style: .recommendation.domain)
        return recommendation.item.isSyndicated ? detailString.addSyndicatedIndicator(with: .recommendation.domain) : detailString
    }

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .recommendation.timeToRead)
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
