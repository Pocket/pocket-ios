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
            } else if apiRequest.isForSlateDetail {
                return Response.slateDetail()
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
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
    
    func test_reportingARecommendation_asBrokenMeta_sendsEvent() {
        let reportExpectation = expectation(description: "A request to snowplow for reporting a recommendation")
        var requestBody: String? = nil
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
            .reportButton.wait().tap()
        
        let report = app.reportView.wait()
        report.brokenMetaButton.verify()
        report.wrongCategoryButton.verify()
        report.sexuallyExplicitButton.verify()
        report.offensiveButton.verify()
        report.misinformationButton.verify()
        report.otherButton.verify().tap()
        report.commentEntry.wait()
        report.submitButton.wait().tap()
        
        wait(for: [reportExpectation], timeout: 1)
        guard let requestBody = requestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }
        
        XCTAssertTrue(requestBody.contains("reason"))
    }
}
