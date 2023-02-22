// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class ItemTypeTests: XCTestCase {
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
            } else if apiRequest.isForSlateDetail(3) {
                return Response.slateDetail(3)
            } else if apiRequest.isForSavesContent {
                return Response.saves("initial-list-item-types-saves")
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
            } else if apiRequest.isToDeleteAnItem {
                return Response.delete()
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

        server.routes.get("/hello2") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello2", ext: "html")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_longItemSlateTitles_areReadable() {
        let home = app.launch().homeView

        home.sectionHeader("Slate 1").wait()
        home.element.swipeUp()

        home.recommendationCell("Slate 1, Recommendation 1").verify()
        home.recommendationCell("Slate 1, Recommendation 2").verify()

        home.element.swipeUp()

        home.sectionHeader("Slate 2").verify()
        home.recommendationCell("Slate 2, Recommendation 1").verify()
    }

    
}
