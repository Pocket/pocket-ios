// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class PullToRefreshTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
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

    func test_myList_pullToRefresh_fetchesNewContent() {
        app.tabBar.myListButton.wait().tap()

        let listView = app.myListView.wait()
        XCTAssertEqual(listView.itemCount, 2)

        server.routes.post("/graphql") { _, _ in
            return Response {
                Status.ok
                Fixture.data(name: "updated-list")
            }
        }

        listView.pullToRefresh()

        listView
            .itemView(matching: "Updated Item 1")
            .wait()

        listView
            .itemView(matching: "Updated Item 2")
            .wait()
    }
}
