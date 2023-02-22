// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Home {}
}

public extension Events.Home {
    /**
     Fired when a card in the `Recent Saves` section scrolls into view
     */
    static func RecentSavesCardImpression(url: URL!, positionInList: Int) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.recent.impression",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Recent Saves` section is shared
     */
    static func RecentSavesCardShare(url: URL!, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.recent.share",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Recent Saves` section is deleted
     */
    static func RecentSavesCardDelete(url: URL!, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.recent.delete",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Recent Saves` section is archived
     */
    static func RecentSavesCardArchive(url: URL!, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.recent.archive",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks a card in the `Recent Saves` section
     */
    static func RecentSavesCardContentOpen(url: URL!, positionInList: Int) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "home.recent.open",
                index: positionInList
            )
        )
    }

    /**
     Fired when a user clicks a card on Home using the /discover API
     */
    static func SlateArticleContentOpen(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "discover.open",
                index: positionInList
            ),
            extraEntities: [
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user sees a card on Home using the /discover API
     */
    static func SlateArticleImpression(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "discover.impression",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user saves a card on Home using the /discover API
     */
    static func SlateArticleSave(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .save(
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .card,
                identifier: "discover.save",
                index: positionInList
            ),
            extraEntities: [
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user unsaves a card on Home using the /discover API
     */
    static func SlateArticleUnsave(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .card,
                identifier: "discover.unsave",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user archives a card on Home using the /discover API
     */
    static func SlateArticleArchive(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .card,
                identifier: "discover.archive",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user shares a card on Home using the /discover API
     */
    static func SlateArticleShare(url: URL!, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "discover.share",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: slateLineupRequestId, experiment: slateExperimentId),
                RecommendationEntity(id: recommendationId, index: UInt(positionInList))
            ]
        )
    }

    /**
     Fired when a user selects the report action on Home using the /discover API
     */
    static func SlateArticleReport(url: URL!, reason: ReportEntity.Reason, comment: String?) -> Engagement {
        return Engagement(
            .report(
                reportEntity: ReportEntity(reason: reason, comment: comment),
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .dialog,
                identifier: "discover.report"
            )
        )
    }
}
