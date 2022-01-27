// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class ArchiveTests: XCTestCase {
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
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_archiveView_displaysArchivedContent() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()
        myList.itemView(matching: "Item 1").wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()

        XCTAssertFalse(myList.itemView(matching: "Item 1").exists)
        XCTAssertFalse(myList.itemView(matching: "Item 2").exists)
    }
}

private func requestIsForArchivedContent(_ request: Request) -> Bool {
    body(of: request)?.contains("\"isArchived\":true") ?? false
}
