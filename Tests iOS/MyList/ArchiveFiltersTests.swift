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
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
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
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves

        saves.selectionSwitcher.archiveButton.wait().tap()
        let archiveItem1 = saves.itemView(matching: "Archived Item 1")
        saves.itemView(matching: "Archived Item 2").verify()

        app.saves.filterButton(for: "Favorites").tap()
        waitForDisappearance(of: archiveItem1)
        saves.itemView(matching: "Archived Item 2").verify()
        app.saves.filterButton(for: "Favorites").tap()

        saves.itemView(matching: "Archived Item 1").verify()
        saves.itemView(matching: "Archived Item 2").verify()
    }

    func test_archiveView_tappingAllPill_togglesDisplayingAllArchivedContent() {
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves

        saves.selectionSwitcher.archiveButton.tap()

        app.saves.filterButton(for: "All").tap()
        let archivedItem1 = saves.itemView(matching: "Archived Item 1")
        saves.itemView(matching: "Archived Item 2").verify()

        app.saves.filterButton(for: "Favorites").tap()
        waitForDisappearance(of: archivedItem1)

        app.saves.filterButton(for: "All").tap()
        saves.itemView(matching: "Archived Item 1").verify()
        saves.itemView(matching: "Archived Item 2").verify()
    }

    func test_archiveView_tappingTaggedFilter_showsFilteredItems() {
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves

        saves.selectionSwitcher.archiveButton.tap()

        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView

        XCTAssertEqual(tagsFilterView.tagCells.count, 6)

        tagsFilterView.tag(matching: "tag 0").tap()

        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "tag 0").verify()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_archiveView_sortingNoTagFilter_showFilteredItems() {
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves

        saves.selectionSwitcher.archiveButton.tap()

        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView

        XCTAssertEqual(tagsFilterView.tagCells.count, 6)

        tagsFilterView.tag(matching: "not tagged").tap()
        waitForDisappearance(of: tagsFilterView)

        XCTAssertEqual(app.saves.itemCells.count, 1)
    }
}
