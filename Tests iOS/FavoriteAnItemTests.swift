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
    var favoriteExpectation: XCTestExpectation?
    var unfavoriteExpectation: XCTestExpectation?

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { [unowned self] request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isToFavoriteAnItem(1) {
                defer { favoriteExpectation?.fulfill() }
                return Response.favorite()
            } else if apiRequest.isToFavoriteAnItem(2) {
                defer { favoriteExpectation?.fulfill() }
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem(1) {
                defer { unfavoriteExpectation?.fulfill() }
                return Response.unfavorite()
            } else if apiRequest.isToUnfavoriteAnItem(2) {
                defer { unfavoriteExpectation?.fulfill() }
                return Response.unfavorite()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
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

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_favoritingAndUnfavoritingAnItemFromList_showsFavoritedIcon_andSyncsWithServer() {
        favoriteExpectation = expectation(description: "A request favorite to the server")
        unfavoriteExpectation = expectation(description: "A request unfavorite to the server")

        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2")
            .wait()

        itemCell.favoriteButton.wait().tap()
        wait(for: [favoriteExpectation!])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        itemCell.favoriteButton.wait().tap()
        wait(for: [unfavoriteExpectation!])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)
    }

    func test_favoritingAndUnfavoritingAnItemFromReader_togglesMenu_andSyncsWithServer() {
        favoriteExpectation = expectation(description: "A request favorite to the server")
        unfavoriteExpectation = expectation(description: "A request unfavorite to the server")

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
            .wait()

        // Favoriting
        do {
            // Tap the favorite button in the overflow menu
            moreButton.tap()
            app.favoriteButton.wait().tap()
            wait(for: [favoriteExpectation!])
        }

        // Unfavoriting
        do {
            // Tap the Unfavorite button from overflow menu
            moreButton.tap()
            app.unfavoriteButton.wait().tap()
            wait(for: [unfavoriteExpectation!])
        }

        moreButton.tap()
        app.favoriteButton.wait()
        XCTAssertFalse(app.unfavoriteButton.exists)
    }

    func test_favoritingAndUnfavoritingAnItemFromArchive_togglesFavoritedIcon_andSyncsWithServer() {
        favoriteExpectation = expectation(description: "A request favorite to the server")
        unfavoriteExpectation = expectation(description: "A request unfavorite to the server")

        app.tabBar.savesButton.wait().tap()
        app.saves.wait().selectionSwitcher.archiveButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Archived Item 1").wait()

        // favorite
        do {
            itemCell.favoriteButton.wait().tap()
            wait(for: [favoriteExpectation!])
            XCTAssertTrue(itemCell.favoriteButton.wait().isFilled)
        }

        // unfavorite
        do {
            itemCell.favoriteButton.wait().tap()
            wait(for: [unfavoriteExpectation!])
            XCTAssertFalse(itemCell.favoriteButton.wait().isFilled)
        }
    }
}
