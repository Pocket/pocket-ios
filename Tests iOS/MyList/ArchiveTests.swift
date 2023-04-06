// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveTests: XCTestCase {
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
            } else if apiRequest.isForItemDetail {
                return Response.itemDetail()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archiveView_displaysArchivedContent() {
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves.verify()
        saves.itemView(at: 0).contains(string: "Item 1")
        saves.itemView(at: 1).contains(string: "Item 2")

        saves.selectionSwitcher.archiveButton.tap()

        saves.itemView(at: 0).contains(string: "Archived Item 1")
        saves.itemView(at: 1).contains(string: "Archived Item 2")

        saves.selectionSwitcher.savesButton.tap()

        saves.itemView(at: 0).contains(string: "Item 1")
        saves.itemView(at: 1).contains(string: "Item 2")
    }

    func test_archiveView_selectingANewSortOrder_SortItems() {
        app.launch().tabBar.savesButton.tap()
        let saves = app.saves
        saves.itemView(matching: "Item 1").verify()

        saves.selectionSwitcher.archiveButton.tap()

        // Sort by Oldest saved
        app.saves.filterButton(for: "All").swipeLeft()
        saves.filterButton(for: "Sort/Filter").tap()
        app.sortMenu.sortOption("Oldest saved").tap()

        saves.itemView(at: 0).contains(string: "Archived Item 2")
        saves.itemView(at: 1).contains(string: "Archived Item 1")

        // Sort by Newest saved
        saves.filterButton(for: "Sort/Filter").tap()
        app.sortMenu.sortOption("Newest saved").tap()

        saves.itemView(at: 0).contains(string: "Archived Item 1")
        saves.itemView(at: 1).contains(string: "Archived Item 2")
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.savesButton.tap()
        app.saves.selectionSwitcher.archiveButton.tap()
        app.saves.itemView(at: 0).tap()

        let expectedContent = [
            "Archived Item 1",
            "Socrates",
            "January 1, 2001",
        ]

        for expectedString in expectedContent {
            app
                .readerView
                .cell(containing: expectedString)
                .verify()
        }
    }

    func test_unarchivingAnItem_removesFromArchive_andAddsToSaves() {
        app.launch().tabBar.savesButton.tap()
        app.saves.selectionSwitcher.archiveButton.tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1")
        itemCell.itemActionButton.tap()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.saves("unarchive")
            } else if apiRequest.isForSavesContent {
                return Response.saves("list-with-unarchived-item")
            }

            fatalError("Unexpected request")
        }

        app.reAddButton.tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.tap()
        itemCell.verify()
    }

    func test_unarchivingAnItem_bySwiping_removesFromArchive_andAddsToSaves() {
        app.launch().tabBar.savesButton.tap()
        app.saves.selectionSwitcher.archiveButton.tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1")
        itemCell.element.swipeLeft()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.saves("unarchive")
            } else if apiRequest.isForSavesContent {
                return Response.saves("list-with-unarchived-item")
            }

            fatalError("Unexpected request")
        }

        app.saves.moveToSavesSwipeButton.tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.tap()
        itemCell.verify()
    }

    func test_tappingTagLabel_showsTagFilter() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let listView = app.saves
        XCTAssertEqual(listView.itemCount, 2)
        let item = listView.itemView(at: 0)
        XCTAssertTrue(item.tagButton.firstMatch.label == "tag 0")
        item.contains(string: "+1")
        item.tagButton.firstMatch.tap()
        app.saves.selectedTagChip(for: "tag 0").verify()
    }
}

extension ArchiveTests {
    func test_archive_showsWebViewWhenItemIsImage() {
        test_archive_showsWebView(at: 0)
    }

    func test_archive_showsWebViewWhenItemIsVideo() {
        test_archive_showsWebView(at: 1)
    }

    func test_archive_showsWebViewWhenItemIsNotAnArticle() {
        test_archive_showsWebView(at: 2)
    }

    func test_archive_showsWebView(at index: Int) {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves("list-for-web-view")
            } else if apiRequest.isForArchivedContent {
                return Response.saves("archived-web-view")
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }

        app.launch().tabBar.savesButton.tap()
        app.saves.selectionSwitcher.archiveButton.tap()
        app.saves.itemView(at: index).tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .verify()
    }
}

private func requestIsForArchivedContent(_ request: Request) -> Bool {
    body(of: request)?.contains("\"isArchived\":true") ?? false
}
