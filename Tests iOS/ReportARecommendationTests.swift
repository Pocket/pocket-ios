import XCTest
import Sails

class ReportARecommendationTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

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
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isForRecommendationDetail {
                return Response.recommendationDetail()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        server.routes.post("/com.snowplowanalytics.snowplow/tp2") { _, _ in
            return Response {
                Status.ok
                Data()
            }
        }

        try server.start()

        app.launch(
            arguments: .bypassSignIn.with(disableSnowplow: false)
        )
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_reportingARecommendationfromHero_asBrokenMeta_sendsEvent() {
        let reportExpectation = expectation(description: "A request to snowplow for reporting a recommendation")
        var requestBody: String?
        server.routes.post("/com.snowplowanalytics.snowplow/tp2") { request, _ in
            requestBody = body(of: request)
            if requestBody?.contains("engagement") == true
                && requestBody?.contains("report") == true
                && requestBody?.contains("reason") == true {
                reportExpectation.fulfill()
            }

            return Response {
                Status.ok
                Data()
            }
        }

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

        wait(for: [reportExpectation])
        guard let requestBody = requestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }

        XCTAssertTrue(requestBody.contains("reason"))
    }

    func test_reportingARecommendationFromCarousel_asBrokenMeta_sendsEvent() {
        let reportExpectation = expectation(description: "A request to snowplow for reporting a recommendation")
        var requestBody: String?
        server.routes.post("/com.snowplowanalytics.snowplow/tp2") { request, _ in
            requestBody = body(of: request)
            if requestBody?.contains("engagement") == true
                && requestBody?.contains("report") == true
                && requestBody?.contains("reason") == true {
                reportExpectation.fulfill()
            }

            return Response {
                Status.ok
                Data()
            }
        }

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

        wait(for: [reportExpectation])
        guard let requestBody = requestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }

        XCTAssertTrue(requestBody.contains("reason"))
    }

    func test_reportingARecommendation_fromReader_showsReportView() {
        app.homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        // Swipe down to a syndicated item
        app.homeView.element.swipeUp()
        app.homeView.recommendationCell("Syndicated Article Rec, 1").wait().tap()

        app.readerView.readerToolbar.moreButton.tap()
        app.reportButton.wait().tap()

        app.reportView.wait()
    }
}
