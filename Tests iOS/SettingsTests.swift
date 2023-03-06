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

        await snowplowMicro.resetSnowplowEvents()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_deleteAccount_free_succeeds() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()

        await loadDeleteConfirmationView()

        freeUser_tapDeleteToggles()

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_premium_succeeds() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()

        premiumUser_tapDeleteToggles()

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_premium_showsError() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForDeleteUser {
                return Response.deleteUserError()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        app.deleteConfirmationView.deleteAccountButton.tap()
        _ = app.deleteConfirmationView.deletingOverlay.waitForExistence(timeout: 5)

        // wait for errror message
    }

    @MainActor
    func test_deleteAccount_free_showsError() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            } else if apiRequest.isForDeleteUser {
                return Response.deleteUserError()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        app.deleteConfirmationView.deleteAccountButton.tap()

        // check loading screen
        // wait for errror message
    }

    /// Utillity to tap and assert the toggles for delete confirmation screen for premium users
    func premiumUser_tapDeleteToggles() {
        app.deleteConfirmationView.understandDeletionSwitch.tap()
        app.deleteConfirmationView.confirmCancelledSwitch.tap()

        XCTAssertTrue(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    /// Utillity to tap and assert the toggles for delete confirmation screen for free users
    func freeUser_tapDeleteToggles() {
        app.deleteConfirmationView.understandDeletionSwitch.tap()

        XCTAssertTrue(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    @MainActor
    /// Helper to load and assert the basics of the delete confirmation view
    func loadDeleteConfirmationView() async {
        app.tabBar.settingsButton.wait().tap()
        XCTAssertTrue(app.settingsView.exists)

        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        XCTAssertNotNil(settingsViewEvent)

        tap_AccountManagement()

        XCTAssertTrue(app.accountManagementView.exists)
        tap_DeleteAccount()
        XCTAssertTrue(app.deleteConfirmationView.exists)

        XCTAssertFalse(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    func tap_AccountManagement() {
        app.settingsView.accountManagementButton.tap()
    }

    func tap_DeleteAccount() {
        app.accountManagementView.deleteAccountButton.tap()
    }
}
