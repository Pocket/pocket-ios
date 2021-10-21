// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class ArchiveAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    func listResponse(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    func slateResponse() -> Response {
        Response {
            Status.ok
            Fixture.data(name: "slates")
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                return self.listResponse()
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
            .userListView
            .itemView(withLabelStartingWith: "Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        let expectRequest = expectation(description: "A request to the server")
        var archiveRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            archiveRequestBody = body(of: request)
            expectRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "archive")
            }
        }

        app.archiveButton.wait().tap()
        XCTAssertFalse(itemCell.exists)

        wait(for: [expectRequest], timeout: 1)
        guard let requestBody = archiveRequestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }
        XCTAssertTrue(requestBody.contains("updateSavedItemArchive"))
        XCTAssertTrue(requestBody.contains("item-2"))
    }

    func test_archivingAnItemFromReader_archivesItem_andPopsBackToList() {
        app.tabBar.myListButton.wait().tap()

        let listView = app.userListView
        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")

        itemCell.wait().tap()

        let expectRequest = expectation(description: "A request to the server")
        var archiveRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            archiveRequestBody = body(of: request)
            expectRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "archive")
            }
        }

        app
            .readerView
            .readerToolbar
            .moreButton
            .wait()
            .tap()

        app.archiveButton.wait().tap()

        listView.wait()
        XCTAssertFalse(itemCell.exists)

        wait(for: [expectRequest], timeout: 1)
        guard let requestBody = archiveRequestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }
        XCTAssertTrue(requestBody.contains("updateSavedItemArchive"))
        XCTAssertTrue(requestBody.contains("item-2"))
    }
}
