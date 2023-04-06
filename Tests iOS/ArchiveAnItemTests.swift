// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var archiveRequestExpectation: XCTestExpectation!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        archiveRequestExpectation = expectation(description: "An archive request to the server")
        archiveRequestExpectation.assertForOverFulfill = true

        server.routes.post("/graphql") { [unowned self] request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isToArchiveAnItem {
                defer { archiveRequestExpectation.fulfill() }
                XCTAssertTrue(apiRequest.contains("item-2"))
                return Response.archive()
            }

            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archivingAnItemFromList_removesItFromList_andSyncsWithServer() {
        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .wait()
            .itemView(matching: "Item 2")
            .wait()

        itemCell
            .itemActionButton
            .wait()
            .tap()

        app.archiveButton.wait().tap()
        wait(for: [archiveRequestExpectation], timeout: 10)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromList_bySwipe_removesItFromList_andSyncWithServer() {
        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .wait()
            .itemView(matching: "Item 2")
            .wait()

        itemCell.element.wait().swipeLeft()

        app
            .saves
            .wait()
            .archiveSwipeButton
            .wait()
            .tap()

        wait(for: [archiveRequestExpectation], timeout: 10)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromReader_archivesItem_andPopsBackToList() {
        app.tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        let itemCell = listView.itemView(matching: "Item 2").wait()

        itemCell.tap()

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"].wait()
        archiveNavButton.tap()
        app.saves.wait()

        wait(for: [archiveRequestExpectation], timeout: 10)
        listView.wait()
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromHomeRecentSaves_archivesItem_andPopsBackToList() {
        let home = app.launch().homeView.wait()

        let itemCell = home.recentSavesView(matching: "Item 2").wait()

        app.tabBar.homeButton.wait().tap()

        itemCell.tap()

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"].wait()
        archiveNavButton.tap()
        app.homeView.wait()

        wait(for: [archiveRequestExpectation])
        waitForDisappearance(of: itemCell)
    }
}
