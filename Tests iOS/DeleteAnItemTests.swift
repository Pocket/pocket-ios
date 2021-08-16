// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class DeleteAnItemTests: XCTestCase {
    var server: Application!
    var app: PocketApp!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketApp(app: uiApp)

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
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_deletingAnItemFromList_removesItFromList_andSyncsWithServer() {
        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData",
                "clearImageCache"
            ],
            environment: [
                "accessToken": "test-access-token"
            ]
        )

        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")
        XCTAssertTrue(itemCell.waitForExistence(timeout: 1))

        itemCell.showActions()

        let deleteButton = itemCell.deleteButton()
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 1))

        let expectRequest = expectation(description: "A request to the server")
        var deleteRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            deleteRequestBody = body(of: request)
            expectRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "delete")
            }
        }

        deleteButton.tap()
        XCTAssertFalse(itemCell.exists)

        wait(for: [expectRequest], timeout: 1)
        guard let requestBody = deleteRequestBody else {
            XCTFail("Expected request body to not be nil")
            return
        }
        XCTAssertTrue(requestBody.contains("deleteSavedItem"))
        XCTAssertTrue(requestBody.contains("item-id-2"))
    }
}
