// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO


class HomeTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    func listResponse(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture
                .load(name: fixtureName)
                .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                .data
        }
    }

    func slateResponse() -> Response {
        Response {
            Status.ok
            Fixture.load(name: "slates")
                .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                .data
        }
    }

    func slateDetailResponse() -> Response {
        Response {
            Status.ok
            Fixture.load(name: "slate-detail")
                .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                .data
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody?.contains("upsertSavedItem") == true {
                return Response {
                    Status.ok
                    Fixture.data(name: "save-item")
                }
            } else if requestBody?.contains("updateSavedItemArchive") == true {
                return Response {
                    Status.ok
                    Fixture.data(name: "archive")
                }
            } else if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else if requestBody!.contains("getSlate(") {
                return self.slateDetailResponse()
            } else {
                return self.listResponse()
            }
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_navigatingToHomeTab_showsASectionForEachSlate() {
        let home = app.homeView

        home.slateHeader("Slate 1").wait()
        home.recommendationCell("Slate 1, Recommendation 1").verify()
        home.recommendationCell("Slate 1, Recommendation 2").verify()

        home.element.swipeUp()

        home.slateHeader("Slate 2").verify()
        home.recommendationCell("Slate 2, Recommendation 1").verify()
    }

    func test_selectingChipInTopicCarousel_showsSlateDetailView() {
        app.homeView.topicChip("Slate 2").wait().tap()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").wait()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 2").verify()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 3").verify()
    }

    func test_tappingRecommendationCell_opensItemInReader() {
        app.homeView.recommendationCell("Slate 1, Recommendation 1").wait().tap()
        app.readerView.cell(containing: "By Jacob & David").wait()
    }

    func test_tappingRecommendationCellInSlateDetailView_opensItemInReader() {
        app.homeView.topicChip("Slate 1").wait().tap()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").wait().tap()
        app.readerView.cell(containing: "By Jacob & David").wait()
    }

    func test_tappingSaveButtonInRecommendationCell_savesItemToList() {
        let cell = app.homeView.recommendationCell("Slate 1, Recommendation 1")
        let saveButton = cell.saveButton.wait()

        let saveRequestExpectation = expectation(description: "A save mutation request")
        let archiveRequestExpectation = expectation(description: "An archive mutation request")
        var promise: EventLoopPromise<Response>?
        var requestBody: String?
        server.routes.post("/graphql") { request, loop in
            requestBody = body(of: request)

            if requestBody?.contains("upsertSavedItem") == true {
                saveRequestExpectation.fulfill()
                promise = loop.makePromise()
                return promise!.futureResult
            } else if requestBody?.contains("updateSavedItemArchive") == true {
                archiveRequestExpectation.fulfill()

                return Response {
                    Status.ok
                    Fixture.data(name: "archive")
                }
            } else {
                fatalError("Unexpected request")
            }
        }

        saveButton.tap()
        XCTAssertEqual(saveButton.label, "Saved")

        app.tabBar.myListButton.tap()
        app.userListView.itemView(withLabelStartingWith: "Slate 1, Recommendation 1").wait()

        wait(for: [saveRequestExpectation], timeout: 1)
        XCTAssertEqual(requestBody?.contains("upsertSavedItem"), true)
        XCTAssertEqual(requestBody?.contains("https:\\/\\/example.com\\/item-1"), true)

        promise?.succeed(Response(status: .ok, content: Fixture.load(name: "save-item").data))
        app.userListView.itemView(withLabelStartingWith: "Saved Recommendation 1").wait()

        app.tabBar.homeButton.tap()
        saveButton.tap()

        XCTAssertEqual(saveButton.label, "Save")
        wait(for: [archiveRequestExpectation], timeout: 1)
        XCTAssertFalse(app.userListView.itemView(withLabelStartingWith: "Slate 1, Recommendation 1").exists)
    }

    func test_tappingSaveButtonInRecommendationCellinSlateDetailView_savesItemToList() {
        app.homeView.topicChip("Slate 1").wait().tap()

        do {
            let saveButton = app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").saveButton.wait()
            saveButton.tap()
            XCTAssertEqual(saveButton.label, "Saved")
        }

        app.tabBar.myListButton.tap()
        app.userListView.itemView(withLabelStartingWith: "Saved Recommendation 1").wait()

        app.tabBar.homeButton.tap()

        do {
            let saveButton = app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").saveButton.wait()
            saveButton.tap()
            XCTAssertEqual(saveButton.label, "Save")
        }
    }

    func test_pullToRefresh_fetchesUpdatedContent() {
        let home = app.homeView
        home.recommendationCell("Slate 1, Recommendation 1").wait()

        server.routes.post("/graphql") { request, _ in
            Response {
                Status.ok
                Fixture.data(name: "updated-slates")
            }
        }

        home.pullToRefresh()

        home.recommendationCell("Updated Slate 1, Recommendation 1").wait()
    }
}
