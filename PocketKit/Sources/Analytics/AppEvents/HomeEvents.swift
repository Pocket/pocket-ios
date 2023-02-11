//
//  HomeEvents.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation

public extension Events {
    struct Home {}
}

public extension Events.Home {
    static func ArticleSave(
        slateLineupId: String,
        slateLineupRequestId: String,
        slateLineupExperimentId: String,
        slatedId: String,
        slateRequestId: String,
        slateExperimentId: String,
        slateIndex: Int,
        positionInSlate: Int,
        itemURL: URL
    ) -> Event {
        return Engagement(
            .save(contentEntity: ContentEntity(url: itemURL)),
            uiEntity: UiEntity(
                .button,
                identifier: "home.article.save",
                index: positionInSlate
            ),
            extraEntities: [
                SlateEntity(
                    id: slatedId,
                    requestID: slateRequestId,
                    experiment: slateExperimentId,
                    index: slateIndex
                ),
                SlateLineupEntity(
                    id: slateLineupId,
                    requestID: slateLineupRequestId,
                    experiment: slateExperimentId
                )
            ]
        )
    }

    static func ArticleReport(
        itemURL: URL,
        reason: ReportEntity.Reason,
        comment: String?
    ) -> Event {
        return Engagement(
            .report(
                reportEntity: ReportEntity(reason: reason, comment: comment),
                contentEntity: ContentEntity(url: itemURL)
            ),
            uiEntity: UiEntity(
                .button,
                identifier: "home.article.report"
            )
        )
    }
}
