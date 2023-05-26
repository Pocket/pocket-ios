// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveTests: XCTestCase {
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
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        try super.tearDownWithError()
    }

    func test_archiveView_displaysArchivedContent() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()
        saves.itemView(matching: "Item 1").wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        XCTAssertTrue(saves.itemView(at: 0).contains(string: "Archived Item 1"))
        XCTAssertTrue(saves.itemView(at: 1).contains(string: "Archived Item 2"))

        XCTAssertFalse(saves.itemView(matching: "Item 1").exists)
        XCTAssertFalse(saves.itemView(matching: "Item 2").exists)
    }

    func test_archiveView_selectingANewSortOrder_SortItems() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()
        saves.itemView(matching: "Item 1").wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        // Sort by Oldest saved
        app.saves.filterButton(for: "All").swipeLeft()
        saves.filterButton(for: "Sort").wait().tap()
        app.sortMenu.sortOption("Oldest saved").wait().tap()

        XCTAssertTrue(saves.itemView(at: 0).contains(string: "Archived Item 2"))
        XCTAssertTrue(saves.itemView(at: 1).contains(string: "Archived Item 1"))

        // Sort by Newest saved
        saves.filterButton(for: "Sort").wait().tap()
        app.sortMenu.sortOption("Newest saved").wait().tap()

        XCTAssertTrue(saves.itemView(at: 0).contains(string: "Archived Item 1"))
        XCTAssertTrue(saves.itemView(at: 1).contains(string: "Archived Item 2"))
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
        var savesCall = 0
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.unarchive(apiRequest: apiRequest)
            } else if apiRequest.isForSavesContent {
                defer { savesCall += 1}
                switch savesCall {
                case 0:
                       return .saves()
                default:
                      return  .saves("list-with-unarchived-item")
                }
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1")
        itemCell.itemActionButton.wait().tap()

        app.reAddButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.tap()
        itemCell.wait()
    }

    func test_unarchivingAnItem_bySwiping_removesFromArchive_andAddsToSaves() {
        var savesCall = 0
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.unarchive(apiRequest: apiRequest)
            } else if apiRequest.isForSavesContent {
                defer { savesCall += 1}
                switch savesCall {
                case 0:
                       return .saves()
                default:
                      return  .saves("list-with-unarchived-item")
                }
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.saves.itemView(matching: "Archived Item 1")
        itemCell.element.swipeLeft()

        app.saves.moveToSavesSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.saves.selectionSwitcher.savesButton.tap()
        itemCell.wait()
    }

    func test_tappingTagLabel_showsTagFilter() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        let listView = app.saves.wait()
        XCTAssertEqual(listView.itemCount, 2)
        let item = listView.itemView(at: 0)
        XCTAssertTrue(item.tagButton.firstMatch.label == "tag 0")
        XCTAssertTrue(item.contains(string: "+1"))
        item.tagButton.firstMatch.tap()
        app.saves.selectedTagChip(for: "tag 0").wait()
    }
}

extension ArchiveTests {
    func test_archive_showsWebViewWhenItemIsImage() {
        server.routes.get("/web-archived-item-1") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        test_archive_showsWebView(at: 0)
    }

    func test_archive_showsWebViewWhenItemIsVideo() {
        server.routes.get("/web-archived-item-2") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        test_archive_showsWebView(at: 1)
    }

    func test_archive_showsWebViewWhenItemIsNotAnArticle() {
        server.routes.get("/web-archived-item-3") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        test_archive_showsWebView(at: 2)
    }

    func test_archive_showsWebView(at index: Int) {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return .slateLineup()
            } else if apiRequest.isForSavesContent {
                return .saves("list-for-web-view")
            } else if apiRequest.isForArchivedContent {
                return .saves("archived-web-view")
            } else if apiRequest.isForTags {
                return .emptyTags()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()
        app.saves.itemView(at: index).wait().tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait(timeout: 10)
    }
}
