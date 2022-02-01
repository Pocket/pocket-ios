// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO


class ArchiveFiltersTests: XCTestCase {
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
            } else if apiRequest.isForFavoritedArchivedContent {
                return Response.favoritedArchivedContent()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
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

    func test_archiveView_tappingFavoritesPill_togglesDisplayingFavoritedArchivedContent() {
        app.launch().tabBar.myListButton.wait().tap()
        let myList = app.myListView.wait()
        myList.itemView(matching: "Item 1").wait()

        myList.selectionSwitcher.archiveButton.wait().tap()

        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()

        XCTAssertFalse(myList.itemView(matching: "Item 1").exists)
        XCTAssertFalse(myList.itemView(matching: "Item 2").exists)
        
        app.myListView.favoritesButton.tap()
        
        waitForDisappearance(of: myList.itemView(matching: "Archived Item 1"))
        waitForDisappearance(of: myList.itemView(matching: "Archived Item 2"))
        
        myList.itemView(matching: "Favorited Archived Item 1").wait()
        myList.itemView(matching: "Favorited Archived Item 2").wait()
        
        app.myListView.favoritesButton.tap()
        
        waitForDisappearance(of: myList.itemView(matching: "Favorited Archived Item 1"))
        waitForDisappearance(of: myList.itemView(matching: "Favorited Archived Item 2"))
        
        myList.itemView(matching: "Archived Item 1").wait()
        myList.itemView(matching: "Archived Item 2").wait()
    }
}

