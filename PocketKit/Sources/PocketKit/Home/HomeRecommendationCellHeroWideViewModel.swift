// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Combine
import Textile
import CoreData

class HomeRecommendationCellHeroWideViewModel {
    let recommendation: Recommendation
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?

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

extension HomeRecommendationCellHeroWideViewModel {
    var imageURL: URL? {
        recommendation.bestImageURL
    }

    var saveButtonMode: RecommendationSaveButton.Mode {
        if recommendation.item.savedItem != nil &&
            recommendation.item.savedItem?.isArchived == false {
            return .saved
        } else {
            return .save
        }
    }

    var attributedHeadline: NSAttributedString? {
        recommendation.bestTitle.flatMap {
            NSAttributedString(string: $0, style: .headline)
        }
    }

    var attributedPublisher: NSAttributedString? {
        (
            recommendation.bestDomain
        ).flatMap { NSAttributedString(string: $0, style: .publisher) }
    }

    var attributedExcerpt: NSAttributedString? {
        recommendation.bestExcerpt.flatMap {
            NSAttributedString(string: $0, style: .excerpt)
        }
    }

    var attributedAuthor: NSAttributedString? {
        recommendation.item.authors.flatMap { authorSet in
            let names = authorSet.compactMap { ($0 as? Author)?.name }
            let formatted = ListFormatter.localizedString(byJoining: names)
            return NSAttributedString(string: formatted, style: .author)
        }
    }
}

private extension Style {
    static let headline: Style = .header.sansSerif.h6.with(color: .ui.black1).with { paragraph in
        paragraph
            .with(lineHeight: .multiplier(1.3))
            .with(lineBreakMode: .byTruncatingTail)
    }

    static let excerpt: Style = .header.sansSerif.p4.with(color: .ui.grey8)
.with { paragraph in
        paragraph
            .with(lineHeight: .multiplier(1.4))
            .with(lineBreakMode: .byTruncatingTail)
    }

    static let publisher: Style = .header.sansSerif.p4.with(color: .ui.grey8).with(weight: .medium)
    static let author: Style = .header.sansSerif.p4.with(color: .ui.grey8)
}
