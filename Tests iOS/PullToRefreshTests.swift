// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class PullToRefreshTests: XCTestCase {
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

    func test_saves_pullToRefresh_fetchesNewContent() {
        var savesCall = 0
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSavesContent {
                defer { savesCall += 1 }
                switch savesCall {
                case 0:
                    return .saves()
                default:
                    return .saves("updated-list")
                }
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        app.tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.itemView(matching: "Item 1").wait()
        listView.itemView(matching: "Item 2").wait()
        XCTAssertEqual(listView.itemCount, 2)
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait 1 second longer then saves refresh safe guard")], timeout: 6.0)

        listView.pullToRefresh()

        listView
            .itemView(matching: "Updated Item 1")
            .wait()

        listView
            .itemView(matching: "Updated Item 2")
            .wait()
        XCTAssertEqual(listView.itemCount, 2)
    }
}
