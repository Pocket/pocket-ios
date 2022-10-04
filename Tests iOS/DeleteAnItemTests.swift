// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class DeleteAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return .slateLineup()
            } else if apiRequest.isForMyListContent {
                return .myList()
            } else if apiRequest.isForArchivedContent {
                return .archivedContent()
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

    func test_deletingAnItemFromList_removesItFromList_andSyncsWithServer() {
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
            XCTAssertFalse(apiRequest.isEmpty)
            XCTAssertTrue(apiRequest.isToDeleteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.delete()
        }

        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        wait(for: [expectRequest], timeout: 1)
        waitForDisappearance(of: itemCell)
    }

    func test_deletingAnItemFromReader_deletesItem_andPopsBackToList() {
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Item 2")
            .wait()

        itemCell.tap()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertFalse(apiRequest.isEmpty)
            XCTAssertTrue(apiRequest.isToDeleteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.delete()
        }

        app
            .readerView
            .readerToolbar
            .moreButton
            .wait()
            .tap()

        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        wait(for: [expectRequest], timeout: 1)

        app.myListView.wait()
        waitForDisappearance(of: itemCell)
    }

    func test_deletingAnItem_fromArchive_removesItFromList_andSyncsWithServer() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.wait().selectionSwitcher.archiveButton.wait().tap()
        let cell = app.myListView.itemView(matching: "Archived Item 1")

        let receivedDeleteRequest = expectation(description: "receivedDeleteRequest")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return .slateLineup()
            } else if apiRequest.isForMyListContent {
                return .myList()
            } else if apiRequest.isForArchivedContent {
                return .archivedContent()
            } else if apiRequest.isToDeleteAnItem {
                receivedDeleteRequest.fulfill()
                XCTAssertFalse(apiRequest.isEmpty)
                XCTAssertTrue(apiRequest.isToDeleteAnItem)
                XCTAssertTrue(apiRequest.contains("archived-item-1"))

                return .delete()
            } else {
                fatalError("Unexpected request")
            }
        }

        cell.itemActionButton.wait().tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()

        wait(for: [receivedDeleteRequest], timeout: 1)
        waitForDisappearance(of: cell)
    }
}
