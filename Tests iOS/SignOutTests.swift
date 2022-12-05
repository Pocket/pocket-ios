// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class SignOutTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = PocketAppElement(app: XCUIApplication())
        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSlateDetail() {
                return Response.slateDetail()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
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

    func test_tappingSignOutshowsLogin() {
        app.tabBar.settingsButton.wait().tap()
        tap_SignOut()

        let account = XCUIApplication()
        account.alerts["Are you sure?"].scrollViews.otherElements.buttons["Sign Out"].wait().tap()
        XCTAssertTrue(app.loggedOutView.exists)
    }

    func test_tappingSignOutCancelshowsAccountsMenu() {
        app.tabBar.settingsButton.wait().tap()
        tap_SignOut()
        let account = XCUIApplication()
        account.alerts["Are you sure?"].scrollViews.otherElements.buttons["Cancel"].wait().tap()
        let cellCount = account.cells.count
        XCTAssertTrue(cellCount > 0)
    }

    func tap_SignOut() {
        app.accountView.signOutButton.tap()
    }
}
