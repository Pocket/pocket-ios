// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveAnItemTests: XCTestCase {
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
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archivingAnItemFromList_removesItFromList_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.archive()
        }

        app.archiveButton.wait().tap()
        wait(for: [expectRequest], timeout: 1)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromList_bySwipe_removesItFromList_andSyncWithServer() {
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Item 2")

        itemCell.element.swipeLeft()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.archive()
        }

        app
            .myListView
            .archiveSwipeButton.wait()
            .tap()

        wait(for: [expectRequest], timeout: 1)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromReader_archivesItem_andPopsBackToList() {
        app.tabBar.myListButton.wait().tap()

        let listView = app.myListView
        let itemCell = listView.itemView(matching: "Item 2")

        itemCell.wait().tap()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.archive()
        }

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"]
        XCTAssert(archiveNavButton.exists)
        archiveNavButton.wait().tap()
        app.myListView.wait()

        wait(for: [expectRequest], timeout: 1)
        listView.wait()
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromHomeRecentSaves_archivesItem_andPopsBackToList() {
        let home = app.launch().homeView.wait()

        let itemCell = home.recentSavesView(matching: "Item 2")

        app.tabBar.homeButton.tap()

        itemCell.wait().tap()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.archive()
        }

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"]
        XCTAssert(archiveNavButton.exists)
        archiveNavButton.wait().tap()
        app.homeView.wait()

        wait(for: [expectRequest])
        waitForDisappearance(of: itemCell)
    }
}
