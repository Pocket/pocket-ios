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
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToFavoriteAnItem() {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem() {
                return Response.unfavorite()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archiveView_tappingFavoritesPill_togglesDisplayingFavoritedArchivedContent() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()
        let archiveItem1 = saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()

        app.saves.filterButton(for: "Favorites").wait().tap()
        waitForDisappearance(of: archiveItem1)
        saves.itemView(matching: "Archived Item 2").wait()
        app.saves.filterButton(for: "Favorites").wait().tap()

        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingAllPill_togglesDisplayingAllArchivedContent() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "All").wait().tap()
        let archivedItem1 = saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()

        app.saves.filterButton(for: "Favorites").wait().tap()
        waitForDisappearance(of: archivedItem1)

        app.saves.filterButton(for: "All").wait().tap()
        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingTaggedFilter_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 6)

        tagsFilterView.tag(matching: "tag 0").wait().tap()

        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "tag 0").wait()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_archiveView_sortingNoTagFilter_showFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.tagCells.count, 6)

        tagsFilterView.tag(matching: "not tagged").wait().tap()
        waitForDisappearance(of: tagsFilterView)

        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }
}
