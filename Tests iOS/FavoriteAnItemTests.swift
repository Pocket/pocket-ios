// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class FavoriteAnItemTests: XCTestCase {
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
            Fixture.load(name: "slates").data
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                return self.listResponse()
            }
        }

        server.routes.post("/v3/oauth/authorize") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content: Fixture.data(name: "successful-auth")
            )
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        server.routes.get("v3/guid") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content: Fixture.data(name: "guid")
            )
        }

        try server.start()

        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData",
                "clearImageCache"
            ],
            environment: [
                "accessToken": "test-access-token",
                "sessionGUID": "session-guid",
                "sessionUserID": "session-user-id",
            ]
        )
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_favoritingAndUnfavoritingAnItemFromList_showsFavoritedIcon_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .userListView
            .itemView(withLabelStartingWith: "Item 2")

        itemCell
            .itemActionButton
            .wait()
            .tap()

        let expectRequest = expectation(description: "A request to the server")
        var favoriteRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            favoriteRequestBody = body(of: request)
            expectRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "favorite")
            }
        }

        app.favoriteButton.wait().tap()

        wait(for: [expectRequest], timeout: 1)
        do {
            guard let requestBody = favoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        itemCell.favoriteIcon.wait()

        let expectUnfavoriteRequest = expectation(description: "A request to the server")
        var unfavoriteRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            unfavoriteRequestBody = body(of: request)
            expectUnfavoriteRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "unfavorite")
            }
        }

        itemCell.itemActionButton.tap()
        app.unfavoriteButton.wait().tap()

        wait(for: [expectUnfavoriteRequest], timeout: 1)
        XCTAssertFalse(itemCell.favoriteIcon.exists)
        do {
            guard let requestBody = unfavoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemUnFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }
    }

    func test_favoritingAndUnfavoritingAnItemFromReader_togglesMenu_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()

        app
            .userListView
            .itemView(withLabelStartingWith: "Item 2")
            .wait()
            .tap()

        let moreButton = app
            .readerView
            .readerToolbar
            .moreButton

        // Favoriting
        do {
            // Set up the request handler
            let expectRequest = expectation(description: "A request to the server")
            var favoriteRequestBody: String?
            server.routes.post("/graphql") { request, loop in
                favoriteRequestBody = body(of: request)
                expectRequest.fulfill()

                return Response {
                    Status.ok
                    Fixture.data(name: "favorite")
                }
            }

            // Tap the favorite button in the overflow menu
            moreButton.wait().tap()
            app.favoriteButton.wait().tap()

            // Assert request was made with correct params
            wait(for: [expectRequest], timeout: 1)
            guard let requestBody = favoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        // Unfavoriting
        do {
            // Set up the request handler
            let expectUnfavoriteRequest = expectation(description: "A request to the server")
            var unfavoriteRequestBody: String?
            server.routes.post("/graphql") { request, loop in
                unfavoriteRequestBody = body(of: request)
                expectUnfavoriteRequest.fulfill()

                return Response {
                    Status.ok
                    Fixture.data(name: "unfavorite")
                }
            }

            // Tap the Unfavorite button from overflow menu
            moreButton.tap()
            app.unfavoriteButton.wait().tap()

            wait(for: [expectUnfavoriteRequest], timeout: 1)
            guard let requestBody = unfavoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemUnFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        moreButton.tap()
        app.favoriteButton.wait()
        XCTAssertFalse(app.unfavoriteButton.exists)
    }
}
