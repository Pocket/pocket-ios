// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class EmptyStateTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        server = Application()

        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        try server.start()
        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        try super.tearDownWithError()
    }

    func testSavesAndArchive_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()

        app.saves.wait()
        do {
            let itemCell2 = app.saves.itemView(matching: "Item 2").wait()
            let itemCell1 = app.saves.itemView(matching: "Item 1").wait()
            XCTAssertEqual(app.saves.wait().itemCells.count, 2)

            swipeItemToArchive(with: itemCell1)
            swipeItemToArchive(with: itemCell2)
        }

        app.saves.emptyStateView(for: "saves-empty-state").wait()
        XCTAssertEqual(app.saves.wait().itemCells.count, 0)

        app.saves.selectionSwitcher.archiveButton.wait().tap()

        do {
            let itemCell1 = app.saves.itemView(matching: "Item 2").wait()
            let itemCell2 = app.saves.itemView(matching: "Item 1").wait()
            let itemCell3 = app.saves.itemView(matching: "Archived Item 2").wait()
            let itemCell4 = app.saves.itemView(matching: "Archived Item 1").wait()
            XCTAssertEqual(app.saves.wait().itemCells.count, 4)
            swipeItemToSaves(with: itemCell1)
            swipeItemToSaves(with: itemCell2)
            swipeItemToSaves(with: itemCell3)
            swipeItemToSaves(with: itemCell4)
        }

        app.saves.emptyStateView(for: "archive-empty-state").wait()
        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
    }

    func testFavorites_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Favorites").wait().tap()
        app.saves.emptyStateView(for: "favorites-empty-state").wait()

        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Favorites").wait().tap()
        app.saves.itemView(at: 0).favoriteButton.tap()

        app.saves.emptyStateView(for: "favorites-empty-state").wait()
    }

    func testTags_showsEmptyStateView() {
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").wait().tap()
        app.saves.tagsFilterView.tag(matching: "not tagged").tap()
        app.saves.emptyStateView(for: "tags-empty-state").wait()
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
