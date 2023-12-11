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
    static func RecentSavesCardImpression(url: String, positionInList: Int) -> Impression {
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
    static func RecentSavesCardShare(url: String, positionInList: Int) -> Engagement {
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
    static func RecentSavesCardDelete(url: String, positionInList: Int) -> Engagement {
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
    static func RecentSavesCardArchive(url: String, positionInList: Int) -> Engagement {
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
    static func RecentSavesCardContentOpen(url: String, positionInList: Int?) -> ContentOpen {
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
     Fired when a card in the `Shared With You` section scrolls into view
     */
    static func SharedWithYouCardImpression(url: String, positionInList: Int) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.sharedWithYou.impression",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Shared With You` section is shared
     */
    static func SharedWithYouCardShare(url: String, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.sharedWithYou.share",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Shared With You` section is deleted
     */
    static func SharedWithYouCardDelete(url: String, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.sharedWithYou.delete",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Shared With You` section is archived
     */
    static func SharedWithYouCardArchive(url: String, positionInList: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "home.sharedWithYou.archive",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a card in the `Shared With You` section is saved
     */
    static func SharedWithYouCardSave(url: String, positionInList: Int) -> Engagement {
        return Engagement(
            .save(
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .button,
                identifier: "home.sharedWithYou.save",
                index: positionInList
            )
        )
    }

    /**
     Fired when a user clicks a card in the `Shared With You` section
     */
    static func SharedWithYouCardContentOpen(url: String, positionInList: Int, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "home.sharedWithYou.open",
                index: positionInList
            )
        )
    }

    /**
     Fired when a user clicks a card on Home using the /discover API
     */
    static func SlateArticleContentOpen(url: String, positionInList: Int?, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int?, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "home.slate.article.open",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }

    /**
     Fired when a user sees a card on Home using the /discover API
     */
    static func SlateArticleImpression(url: String, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.slate.article.impression",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }

    /**
     Fired when a user saves a card on Home using the /discover API
     */
    static func SlateArticleSave(url: String, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .save(
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .button,
                identifier: "home.slate.article.save",
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
     Fired when a user archives a card on Home using the /discover API
     */
    static func SlateArticleArchive(url: String, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "home.slate.article.archive",
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
    static func SlateArticleShare(url: String, positionInList: Int, slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String, slateLineupRequestId: String, slateLineupExperimentId: String, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "home.slate.article.share",
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
    static func SlateArticleReport(url: String, reason: ReportEntity.Reason, comment: String?) -> Engagement {
        return Engagement(
            .report(
                reportEntity: ReportEntity(reason: reason, comment: comment),
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .dialog,
                identifier: "home.slate.article.report"
            )
        )
    }
}
