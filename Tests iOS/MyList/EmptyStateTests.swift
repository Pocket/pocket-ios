// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class EmptyStateTests: XCTestCase {
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
            } else if apiRequest.isForFavoritedArchivedContent {
                return Response.favoritedArchivedContent()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
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

    func testMyListAndArchive_showsEmptyStateView() {
        app.tabBar.myListButton.wait().tap()

        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)

        do {
            let itemCell2 = app.myListView.itemView(matching: "Item 2")
            let itemCell1 = app.myListView.itemView(matching: "Item 1")

            swipeItemToArchive(with: itemCell1)
            swipeItemToArchive(with: itemCell2)
        }

        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)
        XCTAssertTrue(app.myListView.emptyStateView(for: "my-list").exists)

        app.myListView.selectionSwitcher.archiveButton.wait().tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)

        do {
            let itemCell2 = app.myListView.itemView(matching: "Archived Item 2")
            let itemCell1 = app.myListView.itemView(matching: "Archived Item 1")

            swipeItemToMyList(with: itemCell2)
            swipeItemToMyList(with: itemCell1)
        }

        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)
        XCTAssertTrue(app.myListView.emptyStateView(for: "archive").exists)
    }

    func testFavorites_showsEmptyStateView() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)
        XCTAssertTrue(app.myListView.emptyStateView(for: "favorites").exists)

        app.myListView.selectionSwitcher.archiveButton.wait().tap()

        app.myListView.filterButton(for: "Favorites").tap()
        app.myListView.itemView(at: 0).favoriteButton.tap()

        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)
        XCTAssertTrue(app.myListView.emptyStateView(for: "favorites").exists)
    }

    private func swipeItemToArchive(with itemCell: ItemRowElement) {
        itemCell.element.swipeLeft()

        app.myListView.archiveSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)
    }

    private func swipeItemToMyList(with itemCell: ItemRowElement) {
        itemCell.element.swipeLeft()

        app.myListView.moveToMyListSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)
    }
}
