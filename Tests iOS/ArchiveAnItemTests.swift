// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ArchiveAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        try super.tearDownWithError()
    }

    func test_archivingAnItemFromList_removesItFromList_andSyncsWithServer() {
        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToArchiveAnItem {
                defer { expectRequest.fulfill() }
                XCTAssertTrue(apiRequest.isToArchiveAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()

        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        app.archiveButton.wait().tap()
        wait(for: [expectRequest], timeout: 10)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromList_bySwipe_removesItFromList_andSyncWithServer() {
        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToArchiveAnItem {
                defer { expectRequest.fulfill() }
                XCTAssertTrue(apiRequest.isToArchiveAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()

        app.tabBar.savesButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Item 2")

        itemCell.element.swipeLeft()

        app
            .saves
            .archiveSwipeButton.wait()
            .tap()

        wait(for: [expectRequest], timeout: 10)
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromReader_archivesItem_andPopsBackToList() {
        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToArchiveAnItem {
                defer { expectRequest.fulfill() }
                XCTAssertTrue(apiRequest.isToArchiveAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()

        app.tabBar.savesButton.wait().tap()

        let listView = app.saves
        let itemCell = listView.itemView(matching: "Item 2")

        itemCell.wait().tap()

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"]
        XCTAssert(archiveNavButton.exists)
        archiveNavButton.wait().tap()
        app.saves.wait()

        wait(for: [expectRequest], timeout: 10)
        listView.wait()
        waitForDisappearance(of: itemCell)
    }

    func test_archivingAnItemFromHomeRecentSaves_archivesItem_andPopsBackToList() {
        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToArchiveAnItem {
                defer { expectRequest.fulfill() }
                XCTAssertTrue(apiRequest.isToArchiveAnItem)
                XCTAssertTrue(apiRequest.contains("item-2"))
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()

        let home = app.launch().homeView.wait()

        let itemCell = home.recentSavesView(matching: "Item 2")

        app.tabBar.homeButton.tap()

        itemCell.wait().tap()

        let archiveNavButton = XCUIApplication().buttons["archiveNavButton"]
        XCTAssert(archiveNavButton.exists)
        archiveNavButton.wait().tap()
        app.homeView.wait()

        wait(for: [expectRequest])
        waitForDisappearance(of: itemCell)
    }
}
