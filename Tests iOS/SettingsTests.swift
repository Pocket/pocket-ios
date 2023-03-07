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
            } else if apiRequest.isForDeleteUser {
                _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Making the server response slow so we can see the loading screen")], timeout: 5.0)
                return Response.deleteUser()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()

        await loadDeleteConfirmationView()
        freeUser_tapDeleteToggles()
        tap_deleteOnDeleteConfirmation()
        _ = app.loggedOutView.waitForExistence(timeout: 10)
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_premium_succeeds() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForDeleteUser {
                _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Making the server response slow so we can see the loading screen")], timeout: 5.0)
                return Response.deleteUser()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        tap_deleteOnDeleteConfirmation()
        _ = app.loggedOutView.waitForExistence(timeout: 10)
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_premium_showsError() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForDeleteUser {
                _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Making the server response slow so we can see the loading screen")], timeout: 5.0)
                return Response.deleteUserError()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        tap_deleteOnDeleteConfirmation()
        assertsError()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_free_showsError() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            } else if apiRequest.isForDeleteUser {
                _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Making the server response slow so we can see the loading screen")], timeout: 5.0)
                return Response.deleteUserError()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        freeUser_tapDeleteToggles()
        tap_deleteOnDeleteConfirmation()
        assertsError()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Utillity to tap and assert the toggles for delete confirmation screen for premium users
    func premiumUser_tapDeleteToggles() {
        XCTAssertTrue(app.deleteConfirmationView.howToDeleteButton.isHittable)
        app.deleteConfirmationView.understandDeletionSwitch.tap()
        app.deleteConfirmationView.confirmCancelledSwitch.tap()
        XCTAssertFalse(app.deleteConfirmationView.howToDeleteButton.isHittable)
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

    func tap_deleteOnDeleteConfirmation() {
        app.deleteConfirmationView.deleteAccountButton.tap()
        _ = app.deletingAccountOverlay.waitForExistence(timeout: 5)
    }

    func assertsError() {
        let alert = app.alert.wait(timeout: 5.0)
        XCTAssertTrue(alert.exists)
        alert.ok.tap()
    }

    func tap_AccountManagement() {
        app.settingsView.accountManagementButton.tap()
    }

    func tap_DeleteAccount() {
        app.accountManagementView.deleteAccountButton.tap()
    }
}
