// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class FavoriteAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketApp!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketApp(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { _, _ in
            return Response {
                Status.ok
                Fixture
                    .load(name: "initial-list")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data
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
        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")
        XCTAssertTrue(itemCell.waitForExistence(timeout: 1))
        itemCell.showActions()

        let favoriteButton = app.favoriteButton()
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 1))


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

        favoriteButton.tap()
        wait(for: [expectRequest], timeout: 1)


        do {
            guard let requestBody = favoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        let favoriteIcon = itemCell.favoriteIcon()
        XCTAssertTrue(favoriteIcon.waitForExistence(timeout: 1))

        itemCell.showActions()
        let unfavoriteButton = app.unfavoriteButton()
        XCTAssertTrue(unfavoriteButton.waitForExistence(timeout: 1))


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

        unfavoriteButton.tap()

        wait(for: [expectUnfavoriteRequest], timeout: 1)
        XCTAssertFalse(itemCell.favoriteIcon().exists)
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
        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")
        XCTAssertTrue(itemCell.waitForExistence(timeout: 1))

        itemCell.tap()

        let readerView = app.readerView()
        XCTAssertTrue(readerView.waitForExistence())

        app.showItemActions()

        let favoriteButton = app.favoriteButton()
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 1))

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

        favoriteButton.tap()
        wait(for: [expectRequest], timeout: 1)

        do {
            guard let requestBody = favoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        app.showItemActions()
        let unfavoriteButton = app.unfavoriteButton()
        XCTAssertTrue(unfavoriteButton.waitForExistence(timeout: 1))
        XCTAssertFalse(app.favoriteButton().exists)

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

        unfavoriteButton.tap()

        wait(for: [expectUnfavoriteRequest], timeout: 1)
        XCTAssertFalse(itemCell.favoriteIcon().exists)
        do {
            guard let requestBody = unfavoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemUnFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        app.showItemActions()
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 1))
        XCTAssertFalse(unfavoriteButton.exists)
    }
}
