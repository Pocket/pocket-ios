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
            } else if apiRequest.isForSavesContent {
                return Response.saves()
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

    func testSavesAndArchive_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()

        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        do {
            let itemCell2 = app.saves.itemView(matching: "Item 2")
            let itemCell1 = app.saves.itemView(matching: "Item 1")

            swipeItemToArchive(with: itemCell1)
            swipeItemToArchive(with: itemCell2)
        }

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        XCTAssertTrue(app.saves.emptyStateView(for: "saves-empty-state").exists)

        app.saves.selectionSwitcher.archiveButton.wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 4)

        do {
            let itemCell1 = app.saves.itemView(matching: "Item 2")
            let itemCell2 = app.saves.itemView(matching: "Item 1")
            let itemCell3 = app.saves.itemView(matching: "Archived Item 2")
            let itemCell4 = app.saves.itemView(matching: "Archived Item 1")

            swipeItemToSaves(with: itemCell1)
            swipeItemToSaves(with: itemCell2)
            swipeItemToSaves(with: itemCell3)
            swipeItemToSaves(with: itemCell4)
        }

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        XCTAssertTrue(app.saves.emptyStateView(for: "archive-empty-state").exists)
    }

    func testFavorites_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertTrue(app.saves.emptyStateView(for: "favorites-empty-state").exists)

        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Favorites").tap()
        app.saves.itemView(at: 0).favoriteButton.tap()

        XCTAssertTrue(app.saves.emptyStateView(for: "favorites-empty-state").exists)
    }

    func testTags_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        app.saves.tagsFilterView.tag(matching: "not tagged").tap()
        XCTAssertTrue(app.saves.emptyStateView(for: "tags-empty-state").exists)
    }

    private func swipeItemToArchive(with itemCell: ItemRowElement) {
        itemCell.element.swipeLeft()

        app.saves.archiveSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)
    }

    private func swipeItemToSaves(with itemCell: ItemRowElement) {
        itemCell.element.swipeLeft()

        app.saves.moveToSavesSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)
    }
}
