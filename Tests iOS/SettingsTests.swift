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
        app.loggedOutView.wait(timeout: 10.0)
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
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        await tap_deleteOnDeleteConfirmation()
        app.loggedOutView.wait(timeout: 10.0)
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
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
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
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
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
            if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
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
        app.premiumStatusView.wait()
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
        app.deleteConfirmationView.wait()
        app.accountManagementView.wait()
        let events =  await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.click")]
        XCTAssertNotNil(events[0])
        XCTAssertFalse(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    @MainActor
    func tapSettings() async {
        app.tabBar.settingsButton.wait().tap()
        app.settingsView.wait()

        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        XCTAssertNotNil(settingsViewEvent)
    }

    @MainActor
    func tap_deleteOnDeleteConfirmation() async {
        app.deleteConfirmationView.deleteAccountButton.tap()
        // Performing async, so we catch the delete overlay in time.
        async let deleteButtonEventCall = snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.confirm.click")
        app.deletingAccountOverlay.wait()

        let deleteButtonEvent = await deleteButtonEventCall
        XCTAssertNotNil(deleteButtonEvent)
    }

    @MainActor
    func loadExitSurvey() async {
        app.surveyBannerButton.wait()
        let bannerImpression = await snowplowMicro.getFirstEvent(with: "login.accountdelete.banner")
        XCTAssertNotNil(bannerImpression)
        let surveyButton = app.surveyBannerButton
        surveyButton.tap()
        app.webView.wait()
        let events =  await [snowplowMicro.getFirstEvent(with: "login.accountdelete.banner.exitsurvey.click"), snowplowMicro.getFirstEvent(with: "login.accountdelete.exitsurvey")]
        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    func assertsError() {
        let alert = app.alert.wait(timeout: 5.0)
        alert.ok.tap()
    }

    @MainActor
    func tap_AccountManagement() async {
        app.settingsView.accountManagementButton.tap()
        app.accountManagementView.wait()
        let events =  await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.click"), snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management")]
        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    func tap_DeleteAccount() {
        app.accountManagementView.deleteAccountButton.tap()
    }
}
