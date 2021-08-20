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

        server.routes.post("/graphql") { _, _ in
            return Response {
                Status.ok
                Fixture
                    .load(name: "initial-list")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data
            }
        }

        try server.start()

        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData",
                "clearImageCache"
            ],
            environment: [
                "accessToken": "test-access-token",
                "sessionGUID": "session-guid",
                "sessionUserID": "session-user-id",
            ]
        )
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archivingAnItemFromList_removesItFromList_andSyncsWithServer() {
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
        XCTAssertTrue(requestBody.contains("item-id-2"))
    }

    func test_archivingAnItemFromReader_archivesItem_andPopsBackToList() {
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
        XCTAssertTrue(requestBody.contains("item-id-2"))
    }
}
