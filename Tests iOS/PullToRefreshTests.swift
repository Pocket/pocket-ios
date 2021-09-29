// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class PullToRefreshTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    func listResponse(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture
                .load(name: fixtureName)
                .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                .data
        }
    }

    func slateResponse() -> Response {
        Response {
            Status.ok
            Fixture.load(name: "slates")
                .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                .data
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

    func test_myList_pullToRefresh_fetchesNewContent() {
        app.tabBar.myListButton.wait().tap()

        let listView = app.userListView.wait()
        XCTAssertEqual(listView.itemCount, 2)

        server.routes.post("/graphql") { _, _ in
            return Response {
                Status.ok
                Fixture
                    .load(name: "updated-list")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data
            }
        }

        listView.pullToRefresh()

        listView
            .itemView(withLabelStartingWith: "Updated Item 1")
            .wait()

        listView
            .itemView(withLabelStartingWith: "Updated Item 2")
            .wait()
    }
}
