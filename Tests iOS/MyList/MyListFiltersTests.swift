// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class MyListFiltersTests: XCTestCase {
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
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
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

    func test_myListView_tappingFavoritesPill_showsOnlyFavoritedItems() {
        app.launch().tabBar.myListButton.wait().tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)

        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)

        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)
        app.myListView.itemView(at: 0).favoriteButton.tap()

        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 1)
    }

    func test_myListView_tappingAllPill_showsAllItems() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.itemView(at: 0).favoriteButton.tap()

        app.myListView.filterButton(for: "All").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)

        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 1)

        app.myListView.filterButton(for: "All").tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)
    }

    func test_myListView_tappingTaggedPill_showsFilteredItems() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.myListView.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 4)

        tagsFilterView.tag(matching: "not tagged").wait().tap()

        XCTAssertEqual(app.myListView.wait().itemCells.count, 0)
        waitForDisappearance(of: tagsFilterView)

        app.myListView.selectedTagChip(for: "not tagged").wait()
        app.myListView.selectedTagChip(for: "not tagged").buttons.element(boundBy: 0).tap()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 2)
    }
}
