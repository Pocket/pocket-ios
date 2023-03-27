import XCTest
import Sails

class ReportARecommendationTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        await snowplowMicro.resetSnowplowEvents()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSlateDetail() {
                return Response.slateDetail()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isForRecommendationDetail(1) {
                return Response.recommendationDetail(1)
            } else if apiRequest.isForRecommendationDetail(4) {
                return Response.recommendationDetail(4)
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_reportingARecommendationfromHero_asBrokenMeta_sendsEvent() async {
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
        let event = await snowplowMicro.getFirstEvent(with: "discover.report")
        event!.getReportContext()!.assertHas(reason: "other")
        event!.getContentContext()!.assertHas(url: "http://localhost:8080/item-1")
    }

    @MainActor
    func test_reportingARecommendationFromCarousel_asBrokenMeta_sendsEvent() async {
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
        let event = await snowplowMicro.getFirstEvent(with: "discover.report")
        event!.getReportContext()!.assertHas(reason: "other")
        event!.getContentContext()!.assertHas(url: "https://example.com/item-2")
    }

    @MainActor
    func test_reportingARecommendation_fromReader_showsReportView() async {
        app.homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        // Swipe down to a syndicated item
        app.homeView.element.swipeUp()
        app.homeView.recommendationCell("Syndicated Article Slate 2, Rec 2").wait().tap()
        app.readerView.readerToolbar.moreButton.tap()
        app.reportButton.wait().tap()
        app.reportView.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }
}
