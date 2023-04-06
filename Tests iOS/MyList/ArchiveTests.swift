// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var savesCalls = 0

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()
        server.routes.post("/graphql") {[unowned self] request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                defer { savesCalls += 1}
                switch savesCalls {
                case 0:
                    return Response.saves()

                default:
                    return Response.saves("list-with-unarchived-item")
                }
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForItemDetail {
                return Response.itemDetail()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isToSaveAnItem {
                return Response.saves("unarchive")
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
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()
        saves.itemView(at: 0).wait().contains(string: "Item 1")
        saves.itemView(at: 1).wait().contains(string: "Item 2")

        saves.selectionSwitcher.archiveButton.wait().tap()

        saves.itemView(at: 0).wait().contains(string: "Archived Item 1")
        saves.itemView(at: 1).wait().contains(string: "Archived Item 2")

        saves.selectionSwitcher.savesButton.wait().tap()

        saves.itemView(at: 0).wait().contains(string: "Item 1")
        saves.itemView(at: 1).wait().contains(string: "Item 2")
    }

    func test_archiveView_selectingANewSortOrder_SortItems() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()
        saves.itemView(matching: "Item 1").wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        // Sort by Oldest saved
        app.saves.filterButton(for: "All").wait().swipeLeft()
        saves.filterButton(for: "Sort/Filter").wait().tap()
        app.sortMenu.sortOption("Oldest saved").wait().tap()

        saves.itemView(at: 0).wait().contains(string: "Archived Item 2")
        saves.itemView(at: 1).wait().contains(string: "Archived Item 1")

        // Sort by Newest saved
        saves.filterButton(for: "Sort/Filter").wait().tap()
        app.sortMenu.sortOption("Newest saved").wait().tap()

        saves.itemView(at: 0).wait().contains(string: "Archived Item 1")
        saves.itemView(at: 1).wait().contains(string: "Archived Item 2")
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()
        app.saves.itemView(at: 0).wait().tap()

        let expectedContent = [
            "Archived Item 1",
            "Socrates",
            "January 1, 2001",
        ]

        for expectedString in expectedContent {
            app
                .readerView
                .cell(containing: expectedString)
                .wait()
        }
    }

    func test_unarchivingAnItem_removesFromArchive_andAddsToSaves() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1").wait()
        itemCell.itemActionButton.wait().tap()

        app.reAddButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.wait().tap()
        itemCell.wait()
    }

    func test_unarchivingAnItem_bySwiping_removesFromArchive_andAddsToSaves() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1").wait()
        itemCell.element.swipeLeft()

        app.saves.moveToSavesSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.wait().tap()
        itemCell.wait()
    }

    func test_tappingTagLabel_showsTagFilter() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let listView = app.saves.wait()
        XCTAssertEqual(listView.itemCount, 2)
        let item = listView.itemView(at: 0).wait()
        XCTAssertTrue(item.tagButton.firstMatch.label == "tag 0")
        item.contains(string: "+1")
        item.tagButton.firstMatch.wait().tap()
        app.saves.selectedTagChip(for: "tag 0").wait()
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

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()
        app.saves.itemView(at: index).wait().tap()

        app
            .webReaderView
            .wait()
            .staticText(matching: "Hello, world")
            .wait()
    }
}
