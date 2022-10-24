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
            } else {
                fatalError("Unexpected request")
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
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Item 2")
            .wait()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToFavoriteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.favorite()
        }

        itemCell.favoriteButton.tap()
        wait(for: [expectRequest])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        let expectUnfavoriteRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectUnfavoriteRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToUnfavoriteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.unfavorite()
        }

        itemCell.favoriteButton.tap()
        wait(for: [expectUnfavoriteRequest])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)
    }

    func test_favoritingAndUnfavoritingAnItemFromReader_togglesMenu_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(matching: "Item 2")
            .wait()
            .tap()

        let moreButton = app
            .readerView
            .readerToolbar
            .moreButton

        // Favoriting
        do {
            let expectRequest = expectation(description: "A request to the server")
            server.routes.post("/graphql") { request, loop in
                defer { expectRequest.fulfill() }
                let apiRequest = ClientAPIRequest(request)
                XCTAssertTrue(apiRequest.isToFavoriteAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))

                return Response.favorite()
            }

            // Tap the favorite button in the overflow menu
            moreButton.wait().tap()
            app.favoriteButton.wait().tap()
            wait(for: [expectRequest])
        }

        // Unfavoriting
        do {
            let expectUnfavoriteRequest = expectation(description: "A request to the server")
            server.routes.post("/graphql") { request, loop in
                defer { expectUnfavoriteRequest.fulfill() }
                let apiRequest = ClientAPIRequest(request)
                XCTAssertTrue(apiRequest.isToUnfavoriteAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))

                return Response.unfavorite()
            }

            // Tap the Unfavorite button from overflow menu
            moreButton.tap()
            app.unfavoriteButton.wait().tap()
            wait(for: [expectUnfavoriteRequest])
        }

        moreButton.tap()
        app.favoriteButton.wait()
        XCTAssertFalse(app.unfavoriteButton.exists)
    }

    func test_favoritingAndUnfavoritingAnItemFromArchive_togglesFavoritedIcon_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.wait().selectionSwitcher.archiveButton.wait().tap()
        let itemCell = app.myListView.itemView(matching: "Archived Item 1").wait()

        // favorite
        do {
            let expectRequest = expectation(description: "A request to the server")
            server.routes.post("/graphql") { request, loop in
                defer { expectRequest.fulfill() }
                let apiRequest = ClientAPIRequest(request)
                XCTAssertTrue(apiRequest.isToFavoriteAnItem)
                XCTAssertTrue(apiRequest.contains("item-1"))

                return Response.favorite()
            }

            itemCell.wait().favoriteButton.tap()
            wait(for: [expectRequest])
            XCTAssertTrue(itemCell.favoriteButton.isFilled)
        }

        // unfavorite
        do {
            let expectRequest = expectation(description: "A request to the server")
            server.routes.post("/graphql") { request, loop in
                defer { expectRequest.fulfill() }
                let apiRequest = ClientAPIRequest(request)
                XCTAssertTrue(apiRequest.isToUnfavoriteAnItem)
                XCTAssertTrue(apiRequest.contains("item-1"))

                return Response.unfavorite()
            }

            itemCell.favoriteButton.tap()
            wait(for: [expectRequest])
            XCTAssertFalse(itemCell.favoriteButton.isFilled)
        }
    }

}
