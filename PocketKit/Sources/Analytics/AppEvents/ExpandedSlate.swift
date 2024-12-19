// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct ExpandedSlate {}
}

public extension Events.ExpandedSlate {
    /**
     Fired when a user views a slate in detail
     */
    static func slateExpanded(slateId: String, slateRequestId: String, slateExperimentId: String, slateIndex: Int, slateLineupId: String) -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.expandedSlate.impression",
                index: slateIndex
            ),
            extraEntities: [
                SlateEntity(id: slateId, requestID: slateRequestId, experiment: slateExperimentId, index: slateIndex),
                SlateLineupEntity(id: slateLineupId, requestID: "", experiment: ""), // TBD with analytics team but for now we don't have requestID and experimentID
            ]
        )
    }

    /**
     Fired when a user clicks a card on Home using the /discover API
     */
    static func slateArticleContentOpen(url: String, positionInList: Int, recommendationId: String, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "home.expandedSlate.article.open",
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
    static func slateArticleImpression(url: String, positionInList: Int, recommendationId: String) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.expandedSlate.article.impression",
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
    static func slateArticleSave(url: String, positionInList: Int?, recommendationId: String) -> Engagement {
        return Engagement(
            .save(
                contentEntity: ContentEntity(url: url)
            ),
            uiEntity: UiEntity(
                .button,
                identifier: "home.expandedSlate.article.save",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }

    /**
     Fired when a user archives a card on Home using the /discover API
     */
    static func slateArticleArchive(url: String, positionInList: Int, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "home.expandedSlate.article.archive",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }

    /**
     Fired when a user shares a card on Home using the /discover API
     */
    static func slateArticleShare(url: String, positionInList: Int, recommendationId: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "home.expandedSlate.article.share",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }
}
