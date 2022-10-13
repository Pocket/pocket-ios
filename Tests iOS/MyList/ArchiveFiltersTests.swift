// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class ArchiveFiltersTests: XCTestCase {
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

    func test_archiveView_tappingFavoritesPill_togglesDisplayingFavoritedArchivedContent() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()

        myList.selectionSwitcher.archiveButton.wait().tap()
        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()

        app.myListView.filterButton(for: "Favorites").tap()
        waitForDisappearance(of: myList.itemView(matching: "Archived Item 1"))
        myList.itemView(matching: "Favorited Archived Item 1").wait()
        app.myListView.filterButton(for: "Favorites").tap()

        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingAllPill_togglesDisplayingAllArchivedContent() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        app.myListView.filterButton(for: "All").tap()
        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()

        app.myListView.filterButton(for: "Favorites").tap()
        myList.itemView(matching: "Favorited Archived Item 1").wait()

        app.myListView.filterButton(for: "All").tap()
        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingTaggedFilter_showsFilteredItems() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        app.myListView.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.myListView.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 4)

        tagsFilterView.tag(matching: "tag 0").wait().tap()

        waitForDisappearance(of: tagsFilterView)

        app.myListView.selectedTagChip(for: "tag 0").wait()
        XCTAssertEqual(app.myListView.wait().itemCells.count, 1)
    }

    func test_archiveView_sortingNoTagFilter_showFilteredItems() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        app.myListView.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.myListView.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 4)

        tagsFilterView.tag(matching: "not tagged").wait().tap()
        waitForDisappearance(of: tagsFilterView)

        XCTAssertEqual(app.myListView.wait().itemCells.count, 1)
    }
}
