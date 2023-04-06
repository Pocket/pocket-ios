// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class DeleteAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var deletionExpectation: XCTestExpectation!
    var deletedItemString: String!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        deletionExpectation = expectation(description: "A delete request to the server")
        deletionExpectation.assertForOverFulfill = true

        server = Application()
        server.routes.post("/graphql") { [unowned self] request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return .slateLineup()
            } else if apiRequest.isForSavesContent {
                return .saves()
            } else if apiRequest.isForArchivedContent {
                return .archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isToDeleteAnItem {
                defer { deletionExpectation.fulfill() }
                XCTAssertTrue(apiRequest.contains(deletedItemString))
                return Response.delete()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
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
        deletedItemString = "item-2"
        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2").wait()

        itemCell
            .itemActionButton.wait()
            .tap()

        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        wait(for: [deletionExpectation], timeout: 10)
        waitForDisappearance(of: itemCell)
    }

    func test_deletingAnItemFromReader_deletesItem_andPopsBackToList() {
        deletedItemString = "item-2"
        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2")
            .wait()

        itemCell.tap()

        app
            .readerView
            .wait()
            .readerToolbar
            .wait()
            .moreButton
            .wait()
            .tap()

        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        wait(for: [deletionExpectation], timeout: 10)

        app.saves.wait()
        waitForDisappearance(of: itemCell)
    }

    func test_deletingAnItem_fromArchive_removesItFromList_andSyncsWithServer() {
        deletedItemString = "archived-item-1"
        app.tabBar.savesButton.wait().tap()
        app.saves.wait().selectionSwitcher.archiveButton.wait().tap()
        let cell = app.saves.itemView(matching: "Archived Item 1").wait()

        cell.itemActionButton.wait().tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()

        wait(for: [deletionExpectation], timeout: 10)
        waitForDisappearance(of: cell)
    }
}
