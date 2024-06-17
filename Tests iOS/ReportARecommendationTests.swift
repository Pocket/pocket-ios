// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ReportARecommendationTests: PocketXCTestCase {
    @MainActor
    func test_reportingARecommendationfromHero_asBrokenMeta_sendsEvent() async {
        app.launch()
        app.homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .overflowButton.wait().tap()

        app.reportButton.wait().tap()

        let report = app.reportView.wait()
        report.brokenMetaButton.verify()
        report.wrongCategoryButton.verify()
        report.sexuallyExplicitButton.verify()
        report.offensiveButton.verify()
        report.misinformationButton.verify()
        report.otherButton.verify().tap()
        report.commentEntry.wait()
        report.submitButton.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let event = await snowplowMicro.getFirstEvent(with: "home.slate.article.report")
        event!.getReportContext()!.assertHas(reason: "other")
        event!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/slate-1-rec-1")
        event!.getCorpusRecommendationContext()!.assertHas(corpusRecomendationID: "7eb25abf-39f6-4d04-91e9-7485bbf7333b")
    }

    @MainActor
    func test_reportingARecommendationFromCarousel_asBrokenMeta_sendsEvent() async {
        app.launch()
        let coordinateToScroll = app.homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .element.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)
            )

        coordinateToScroll.press(
            forDuration: 0.1,
            thenDragTo: coordinateToScroll.withOffset(CGVector(dx: 0, dy: -50)),
            withVelocity: .default,
            thenHoldForDuration: 0.1
        )

        app.homeView
            .recommendationCell("Slate 1, Recommendation 2")
            .overflowButton.wait().tap()

        app.reportButton.wait().tap()

        let report = app.reportView.wait()
        report.brokenMetaButton.verify()
        report.wrongCategoryButton.verify()
        report.sexuallyExplicitButton.verify()
        report.offensiveButton.verify()
        report.misinformationButton.verify()
        report.otherButton.verify().tap()
        report.commentEntry.wait()
        report.submitButton.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let event = await snowplowMicro.getFirstEvent(with: "home.slate.article.report")
        event!.getReportContext()!.assertHas(reason: "other")
        event!.getContentContext()!.assertHas(url: "https://given.example.com/slate-1-rec-2")
        event!.getCorpusRecommendationContext()!.assertHas(corpusRecomendationID: "d88c1280-0128-4767-84e2-a6fa0d2832fa")
    }

    @MainActor
    func test_reportingARecommendation_fromReader_showsReportView() async {
        app.launch()
        app.homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        // Swipe down to a syndicated item
        app.homeView.element.swipeUp()
        app.homeView.recommendationCell("Slate 1, Recommendation 2").wait().tap()
        app.readerView.readerToolbar.moreButton.tap()
        app.reportButton.wait().tap()
        app.reportView.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let reportEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.report")
        reportEvent!.getUIContext()!.assertHas(type: "button")
        reportEvent!.getContentContext()!.assertHas(url: "https://getpocket.com/explore/item/article-2")
        XCTAssertNil(reportEvent!.getCorpusRecommendationContext())
    }
}
