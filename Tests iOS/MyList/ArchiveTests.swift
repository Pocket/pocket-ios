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
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForItemDetail {
                return Response.itemDetail()
            } else {
                fatalError("Unexpected request")
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
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()
        myList.itemView(matching: "Item 1").wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        XCTAssertTrue(myList.itemView(at: 0).contains(string: "Archived Item 1"))
        XCTAssertTrue(myList.itemView(at: 1).contains(string: "Archived Item 2"))

        XCTAssertFalse(myList.itemView(matching: "Item 1").exists)
        XCTAssertFalse(myList.itemView(matching: "Item 2").exists)
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.selectionSwitcher.archiveButton.wait().tap()
        app.myListView.itemView(at: 0).wait().tap()

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

    func test_unarchivingAnItem_removesFromArchive_andAddsToMyList() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.myListView.itemView(matching: "Archived Item 1")
        itemCell.itemActionButton.wait().tap()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.myList("unarchive")
            } else if apiRequest.isForMyListContent {
                return Response.myList("list-with-unarchived-item")
            }

            fatalError("Unexpected request")
        }

        app.reAddButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.myListView.selectionSwitcher.myListButton.tap()
        itemCell.wait()
    }

    func test_unarchivingAnItem_bySwiping_removesFromArchive_andAddsToMyList() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app.myListView.itemView(matching: "Archived Item 1")
        itemCell.element.swipeLeft()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                return Response.myList("unarchive")
            } else if apiRequest.isForMyListContent {
                return Response.myList("list-with-unarchived-item")
            }

            fatalError("Unexpected request")
        }

        app.myListView.moveToMyListSwipeButton.wait().tap()
        waitForDisappearance(of: itemCell)

        app.myListView.selectionSwitcher.myListButton.tap()
        itemCell.wait()
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
            } else if apiRequest.isForMyListContent {
                return Response.myList("list-for-web-view")
            } else if apiRequest.isForArchivedContent {
                return Response.myList("archived-web-view")
            } else {
                fatalError("Unexpected request")
            }
        }

        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.selectionSwitcher.archiveButton.wait().tap()
        app.myListView.itemView(at: index).wait().tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()
    }
}

private func requestIsForArchivedContent(_ request: Request) -> Bool {
    body(of: request)?.contains("\"isArchived\":true") ?? false
}
