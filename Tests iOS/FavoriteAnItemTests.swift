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

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        try super.tearDownWithError()
    }

    func test_favoritingAndUnfavoritingAnItemFromList_showsFavoritedIcon_andSyncsWithServer() {
        let expectUnfavoriteRequest = expectation(description: "A request to unfavorite")
        let expectFavoriteRequest = expectation(description: "A request to favorite")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToUnfavoriteAnItem {
                defer { expectUnfavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "saved-item-2")
                return .unfavorite(apiRequest: apiRequest)
            } else if apiRequest.isToFavoriteAnItem {
                defer { expectFavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "saved-item-2")
                return .favorite(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2")
            .wait()

        itemCell.favoriteButton.tap()
        wait(for: [expectFavoriteRequest])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        itemCell.favoriteButton.tap()
        wait(for: [expectUnfavoriteRequest])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)
    }

    func test_favoritingAndUnfavoritingAnItemFromReader_togglesMenu_andSyncsWithServer() {
        let expectUnfavoriteRequest = expectation(description: "A request to unfavorite")
        let expectFavoriteRequest = expectation(description: "A request to favorite")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToUnfavoriteAnItem {
                defer { expectUnfavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "saved-item-2")
                return .unfavorite(apiRequest: apiRequest)
            } else if apiRequest.isToFavoriteAnItem {
                defer { expectFavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "saved-item-2")
                return .favorite(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        app.tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(matching: "Item 2")
            .wait()
            .tap()

        let moreButton = app
            .readerView
            .readerToolbar
            .moreButton

        // Favoriting
        // Tap the favorite button in the overflow menu
        moreButton.wait().tap()
        app.favoriteButton.wait().tap()
        wait(for: [expectFavoriteRequest])

        // Unfavoriting
        // Tap the Unfavorite button from overflow menu
        moreButton.tap()
        app.unfavoriteButton.wait().tap()
        wait(for: [expectUnfavoriteRequest])

        moreButton.tap()
        app.favoriteButton.wait()
        XCTAssertFalse(app.unfavoriteButton.exists)
    }

    func test_favoritingAndUnfavoritingAnItemFromArchive_togglesFavoritedIcon_andSyncsWithServer() {
        let expectUnfavoriteRequest = expectation(description: "A request to unfavorite")
        let expectFavoriteRequest = expectation(description: "A request to favorite")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToUnfavoriteAnItem {
                defer { expectUnfavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "archived-item-1")
                return .unfavorite(apiRequest: apiRequest)
            } else if apiRequest.isToFavoriteAnItem {
                defer { expectFavoriteRequest.fulfill() }
                XCTAssertEqual(apiRequest.variableItemId, "archived-item-1")
                return .favorite(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        app.tabBar.savesButton.wait().tap()
        app.saves.wait().selectionSwitcher.archiveButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Archived Item 1").wait()

        // favorite
        itemCell.wait().favoriteButton.tap()
        wait(for: [expectFavoriteRequest])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        // unfavorite
        itemCell.favoriteButton.tap()
        wait(for: [expectUnfavoriteRequest])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)
    }
}
