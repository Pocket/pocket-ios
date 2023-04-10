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

        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
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
        app.saves.itemView(at: 0).wait().favoriteButton.tap()

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
        tagsFilterView.tag(matching: "not tagged").wait()

        tagsFilterView.recentTagCells.element.wait()
        XCTAssertEqual(tagsFilterView.recentTagCells.count, 3)

        scrollTo(element: tagsFilterView.allTagCells(matching: "tag 2"), in: tagsFilterView.element, direction: .up)
//        XCTAssertEqual(tagsFilterView.allTagSectionCells.count, 6)

        tagsFilterView.tag(matching: "not tagged").wait().tap()

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "not tagged").wait()
        app.saves.selectedTagChip(for: "not tagged").buttons.element(boundBy: 0).tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }
}
