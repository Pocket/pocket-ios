// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class AddTagsItemTests: XCTestCase {
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
            } else if apiRequest.isForRecommendationDetail {
                return Response.recommendationDetail()
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

    func test_addTagsToItemFromSaves_showsAddTagsInOverflowMenu() {
        app.tabBar.myListButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        app.addTagsButton.wait()
    }
    
    func test_addTagsToItemFromArchive_showsAddTagsInOverflowMenu() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.wait().selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app
            .myListView
            .itemView(matching: "Archived Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        app.addTagsButton.wait()
    }
    
    func test_addTagsToSavedItemFromReader_showsAddTagsInOverflowMenu() {
        app.tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(matching: "Item 2")
            .wait()
            .tap()

        app
            .readerView
            .readerToolbar
            .moreButton.wait()
            .tap()

        app
            .addTagsButton.wait()
    }
}
