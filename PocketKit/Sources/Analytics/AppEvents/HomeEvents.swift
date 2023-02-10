//
//  HomeEvents.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation

public class HomeArticleContentOpen: AppEvent {
    public init(
        slateTitle: String,
        positionInSlate: Int,
        itemURL: URL
    ) {
        super.init(
            event: ContentOpenEvent(),
            entities: [
                UiEntity(
                    type: .card,
                    identifier: "home.article.open",
                    componentDetail: slateTitle,
                    index: positionInSlate
                ),
                ContentEntity(url: itemURL)
            ]
        )
    }
}

public class HomeArticleSave: AppEvent {
    public init(
        slateLineupId: String,
        slateLineupRequestId: String,
        slateLineupExperimentId: String,
        slatedId: String,
        slateRequestId: String,
        slateExperimentId: String,
        slateIndex: Int,
        positionInSlate: Int,
        itemURL: URL
    ) {
        super.init(
            event: SnowplowEngagement(type: .save),
            entities: [
                UiEntity(
                    type: .button,
                    identifier: "home.article.save",
                    index: positionInSlate
                ),
                ContentEntity(url: itemURL),
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
}

public class HomeArticleOverflowClick: AppEvent {
    public init(slateTitle: String, positionInSlate: Int, itemURL: URL) {
        super.init(
            event: SnowplowEngagement(),
            entities: [
                UiEntity(
                    type: .button,
                    identifier: "home.article.overflow.click",
                    componentDetail: slateTitle,
                    index: positionInSlate
                ),
                ContentEntity(url: itemURL)
            ]
        )
    }
}

public class HomeArticleReport: AppEvent {
    public init(itemURL: URL, reason: ReportEntity.Reason, comment: String?) {
        super.init(
            event: SnowplowEngagement(type: .report),
            entities: [
                UiEntity(
                    type: .button,
                    identifier: "home.article.report"
                ),
                ContentEntity(url: itemURL),
                ReportEntity(reason: reason, comment: comment)
            ]
        )
    }
}
