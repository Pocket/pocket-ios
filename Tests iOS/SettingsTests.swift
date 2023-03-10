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
        await tap_deleteOnDeleteConfirmation()
        _ = app.loggedOutView.waitForExistence(timeout: 10)
        await loadExitSurvey()
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
        await tap_deleteOnDeleteConfirmation()
        _ = app.loggedOutView.waitForExistence(timeout: 10)
        await loadExitSurvey()
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
        await tap_deleteOnDeleteConfirmation()
        assertsError()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_deleteAccount_premium_showsHelp() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        app.deleteConfirmationView.howToDeleteButton.tap()
        _ = app.webView.waitForExistence(timeout: 5)

        let events = await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.help-cancel-premium"), snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.help-cancel-premium.click")]

        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])

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
        await tap_deleteOnDeleteConfirmation()
        assertsError()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_premiumStatus_success() async {
        let saveRequestExpectation = expectation(description: "A save mutation request")
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            return Response.fallbackResponses(apiRequest: apiRequest)
        }
        server.routes.post("/purchase_status") { request, _ in
            saveRequestExpectation.fulfill()
            return Response.premiumStatus()
        }

        app.launch()
        await tapSettings()
        await tapPremiumSubscription()
        wait(for: [saveRequestExpectation])
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func tapPremiumSubscription() async {
        app.settingsView.premiumSubscriptionButton.tap()
        XCTAssertTrue(app.premiumStatusView.exists)
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
        await tapSettings()
        await tap_AccountManagement()
        tap_DeleteAccount()
        XCTAssertTrue(app.deleteConfirmationView.exists)
        XCTAssertTrue(app.accountManagementView.exists)
        let events2 =  await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete"), snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.click")]
        XCTAssertNotNil(events2[0])
        XCTAssertNotNil(events2[1])
        XCTAssertFalse(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    @MainActor
    func tapSettings() async {
        app.tabBar.settingsButton.wait().tap()
//        XCTAssertTrue(app.settingsView.exists)

        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
//        XCTAssertNotNil(settingsViewEvent)
    }

    @MainActor
    func tap_deleteOnDeleteConfirmation() async {
        app.deleteConfirmationView.deleteAccountButton.tap()
        // Performing async, so we catch the delete overlay in time.
        async let deleteButtonEventCall = snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.confirm.click")
        _ = app.deletingAccountOverlay.waitForExistence(timeout: 5)

        let deleteButtonEvent = await deleteButtonEventCall
        XCTAssertNotNil(deleteButtonEvent)
    }

    @MainActor
    func loadExitSurvey() async {
        _ = app.surveyBannerButton.waitForExistence(timeout: 5.0)
        let bannerImpression = await snowplowMicro.getFirstEvent(with: "login.accountdelete.banner")
        XCTAssertNotNil(bannerImpression)
        let surveyButton = app.surveyBannerButton
        surveyButton.tap()
        _ = app.webView.waitForExistence(timeout: 5.0)
        let events =  await [snowplowMicro.getFirstEvent(with: "login.accountdelete.banner.exitsurvey.click"), snowplowMicro.getFirstEvent(with: "login.accountdelete.exitsurvey")]
        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    func assertsError() {
        let alert = app.alert.wait(timeout: 5.0)
        XCTAssertTrue(alert.exists)
        alert.ok.tap()
    }

    @MainActor
    func tap_AccountManagement() async {
        app.settingsView.accountManagementButton.tap()
        XCTAssertTrue(app.accountManagementView.exists)
        let events =  await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.click"), snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management")]
        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    func tap_DeleteAccount() {
        app.accountManagementView.deleteAccountButton.tap()
    }
}
