// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ShareAnItemTests: XCTestCase {
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
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isForSlateDetail() {
                return Response.slateDetail()
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

    func test_sharingAnItemFromList_presentsShareSheet() {
        app.tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(matching: "Item 2")
            .shareButton.wait()
            .tap()

        app.shareSheet.wait()
    }

    func test_sharingAnItemFromReader_presentsShareSheet() {
        app.tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(matching: "Item 2")
            .wait()
            .tap()

        app
            .readerView
            .readerToolbar
            .moreButton.wait()
            .tap()

        app
            .shareButton.wait()
            .tap()

        app.shareSheet.wait()
    }

    func test_shareFromHome_sharingARecommendation_sharingFromSlate() {
        let cell = app.launch().homeView.recommendationCell("Slate 1, Recommendation 1")

        cell.overflowButton.wait().tap()
        app.shareButton.wait().tap()

        app.shareSheet.wait()
    }

    func test_shareFromHome_sharingARecommendation_sharingFromSlateDetails() {
        app.launch()
            .homeView
            .sectionHeader("Slate 1")
            .seeAllButton
            .wait().tap()

        let cell = app.slateDetailView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        cell.overflowButton.wait().tap()
        app.shareButton.wait().tap()

        app.shareSheet.wait()
    }
}
