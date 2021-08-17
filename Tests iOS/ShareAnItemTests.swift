// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class ShareAnItemTests: XCTestCase {
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

    func test_sharingAnItemFromList_presentsShareSheet() {
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

        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")
        XCTAssertTrue(itemCell.waitForExistence(timeout: 1))

        itemCell.showActions()

        let shareButton = app.shareButton()
        XCTAssertTrue(shareButton.waitForExistence(timeout: 1))

        shareButton.tap()

        let shareSheet = app.shareSheet()
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 1))
    }
}
