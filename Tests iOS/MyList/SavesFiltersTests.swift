// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class SavesFiltersTests: XCTestCase {
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
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_savesView_tappingFavoritesPill_showsOnlyFavoritedItems() {
        app.launch().tabBar.savesButton.wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 0)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
        app.saves.itemView(at: 0).favoriteButton.tap()

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_savesView_tappingAllPill_showsAllItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(at: 0).favoriteButton.tap()

        app.saves.filterButton(for: "All").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)

        app.saves.filterButton(for: "All").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }

    func test_savesView_tappingTaggedPill_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 4)

        tagsFilterView.tag(matching: "not tagged").wait().tap()

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "not tagged").wait()
        app.saves.selectedTagChip(for: "not tagged").buttons.element(boundBy: 0).tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }
}
