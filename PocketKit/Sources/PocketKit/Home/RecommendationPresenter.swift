// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Textile
import Foundation


private extension Style {
    static let title: Style = .header.sansSerif.h6.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let miniTitle: Style = .header.sansSerif.h7.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let subtitle: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let excerpt: Style = .header.sansSerif.p4.with(color: .ui.grey4).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
}

struct RecommendationPresenter {
    private let recommendation: Slate.Recommendation

    init(recommendation: Slate.Recommendation) {
        self.recommendation = recommendation
    }

    var attributedTitle: NSAttributedString {
        return NSAttributedString(recommendation.title ?? "", style: .title)
    }

    var attributedTitleForMeasurement: NSAttributedString {
        let style = Style.title.with { paragraph in
            paragraph.with(lineBreakMode: .none)
        }

        return NSAttributedString(recommendation.title ?? "", style: style)
    }

    var attributedDetail: NSAttributedString {
        return NSAttributedString(detail, style: .subtitle)
    }

    var attributedDetailForMeasurement: NSAttributedString {
        let style = Style.subtitle.with { paragraph in
            paragraph.with(lineBreakMode: .none)
        }

        return NSAttributedString(detail, style: style)
    }

    private var detail: String {
        [domain, timeToRead].compactMap { $0 }.joined(separator: " • ")
    }

    var attributedExcerpt: NSAttributedString {
        return NSAttributedString(recommendation.excerpt ?? "", style: .excerpt)
    }

    var attributedExcerptForMeasurement: NSAttributedString {
        let style = Style.excerpt.with { paragraph in
            paragraph.with(lineBreakMode: .none)
        }

        return NSAttributedString(recommendation.excerpt ?? "", style: style)
    }

    private var domain: String? {
        recommendation.domainMetadata?.name ?? recommendation.domain
    }

    private var timeToRead: String? {
        guard let timeToRead = recommendation.timeToRead else {
            return nil
        }

        return timeToRead > 0 ? "\(timeToRead) min" : nil
    }
}
