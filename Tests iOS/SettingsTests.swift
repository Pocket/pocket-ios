// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class SettingsTest: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        app = PocketAppElement(app: XCUIApplication())
        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        await snowplowMicro.resetSnowplowEvents()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_tappingDeletingAccountShowsDeleteConfirmation() async {
        app.launch()
        app.tabBar.settingsButton.wait().tap()
        XCTAssertTrue(app.settingsView.exists)

        
        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        XCTAssertNotNil(settingsViewEvent)

        tap_AccountManagement()

        XCTAssertTrue(app.accountManagementView.exists)

        tap_DeleteAccount()
        
        XCTAssertTrue(app.deleteConfirmationView.exists)

        app.deleteConfirmationView.understandDeletionToggle.tap()
       
        app.deleteConfirmationView.deleteAccountButton.tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    func tap_AccountManagement() {
        app.settingsView.accountManagementButton.tap()
    }

    func tap_DeleteAccount() {
        app.accountManagementView.deleteAccountButton.tap()
    }
}
