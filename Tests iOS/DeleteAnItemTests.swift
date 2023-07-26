// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class DeleteAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

        server = Application()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        try super.tearDownWithError()
    }

    func test_deletingAnItemFromList_removesItFromList_andSyncsWithServer() {
        let deletionExpectation = expectation(description: "A delete request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteAnItem {
                defer { deletionExpectation.fulfill() }
                XCTAssertEqual(apiRequest.variableGivenURL, "https://example.com/item-2")
                return .delete(apiRequest: apiRequest)
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()

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

    @MainActor
    func test_deletingAnItemFromReader_deletesItem_andPopsBackToList() async {
        let deletionExpectation = expectation(description: "A delete request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteAnItem {
                defer { deletionExpectation.fulfill() }
                XCTAssertEqual(apiRequest.variableGivenURL, "https://example.com/item-2")
                return .delete(apiRequest: apiRequest)
            }

            return Response.fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let deleteEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.delete")
        deleteEvent!.getUIContext()!.assertHas(type: "button")
        deleteEvent!.getContentContext()!.assertHas(url: "https://example.com/item-2")
    }

    func test_deletingAnItem_fromArchive_removesItFromList_andSyncsWithServer() {
        let deletionExpectation = expectation(description: "A delete request to the server")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteAnItem {
                defer { deletionExpectation.fulfill() }
                XCTAssertEqual(apiRequest.variableGivenURL, "http://example.com/items/archived-item-1")
                return .delete(apiRequest: apiRequest)
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
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
