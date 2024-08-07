// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class SettingsTest: PocketXCTestCase {
    @MainActor
    func test_deleteAccount_free_succeeds() async {
        var deletePromise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            } else if apiRequest.isForDeleteUser {
                deletePromise = eventLoop.makePromise(of: Response.self)
                return deletePromise!.futureResult
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()

        await loadDeleteConfirmationView()
        freeUser_tapDeleteToggles()
        await tap_deleteOnDeleteConfirmation(deletePromise: &deletePromise)
        // go back to anonymous home
        app.homeView.wait()
        deletePromise = nil
    }

    @MainActor
    func test_deleteAccount_premium_succeeds() async {
        var deletePromise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForDeleteUser {
                deletePromise = eventLoop.makePromise(of: Response.self)
                return deletePromise!.futureResult
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        await tap_deleteOnDeleteConfirmation(deletePromise: &deletePromise)
        app.homeView.wait()
        deletePromise = nil
    }

    @MainActor
    func test_deleteAccount_premium_showsError() async {
        var deletePromise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForDeleteUser {
                deletePromise = eventLoop.makePromise(of: Response.self)
                return deletePromise!.futureResult
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        premiumUser_tapDeleteToggles()
        await tap_deleteOnDeleteConfirmation(deletePromise: &deletePromise, success: false)
        assertsError()
        deletePromise = nil
    }

    @MainActor
    func test_deleteAccount_premium_showsHelp() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves()
            } else if apiRequest.isForUserDetails {
                return .premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        app.deleteConfirmationView.howToDeleteButton.tap()
        _ = app.webView.wait()

        let events = await [snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.help-cancel-premium"), snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.help-cancel-premium.click")]

        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    @MainActor
    func test_deleteAccount_free_showsError() async {
        var deletePromise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            } else if apiRequest.isForDeleteUser {
                deletePromise = eventLoop.makePromise(of: Response.self)
                return deletePromise!.futureResult
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadDeleteConfirmationView()
        freeUser_tapDeleteToggles()
        await tap_deleteOnDeleteConfirmation(deletePromise: &deletePromise, success: false)
        assertsError()
    }

    @MainActor
    func test_premiumStatus_success() async {
        let saveRequestExpectation = expectation(description: "A save mutation request")
        saveRequestExpectation.assertForOverFulfill = false
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForUserDetails {
                return .premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        server.routes.post("/purchase_status") { request, _ -> Response in
            saveRequestExpectation.fulfill()
            return .premiumStatus()
        }

        app.launch()
        await tapSettings()
        await tapPremiumSubscription()
        wait(for: [saveRequestExpectation])
    }

    @MainActor
    func tapPremiumSubscription() async {
        app.settingsView.premiumSubscriptionButton.tap()
        app.premiumStatusView.wait()
    }

    /// Utillity to tap and assert the toggles for delete confirmation screen for premium users
    func premiumUser_tapDeleteToggles() {
        XCTAssertTrue(app.deleteConfirmationView.howToDeleteButton.isHittable)
        app.deleteConfirmationView.understandDeletionSwitch.wait().tap()
        app.deleteConfirmationView.confirmCancelledSwitch.wait().tap()
        XCTAssertFalse(app.deleteConfirmationView.howToDeleteButton.isHittable)
        XCTAssertTrue(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    /// Utillity to tap and assert the toggles for delete confirmation screen for free users
    func freeUser_tapDeleteToggles() {
        app.deleteConfirmationView.understandDeletionSwitch.wait().tap()
        XCTAssertTrue(app.deleteConfirmationView.deleteAccountButton.isEnabled)
    }

    /// Helper to load and assert the basics of the delete confirmation view
    @MainActor
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
    func tap_deleteOnDeleteConfirmation(deletePromise: inout EventLoopPromise<Response>?, success: Bool = true) async {
        app.deleteConfirmationView.deleteAccountButton.tap()
        async let deleteButtonEventCall = snowplowMicro.getFirstEvent(with: "global-nav.settings.account-management.delete.confirm.click")
        app.deletingAccountOverlay.wait()
        if success {
            deletePromise!.completeWith(.success(.deleteUser()))
        } else {
            deletePromise!.completeWith(.success(.deleteUserError()))
        }

        let deleteButtonEvent = await deleteButtonEventCall
        XCTAssertNotNil(deleteButtonEvent)
    }

    @MainActor
    func loadExitSurvey() async {
        app.surveyBannerButton.wait()
        let bannerImpression = await snowplowMicro.getFirstEvent(with: "login.accountdelete.banner")
        XCTAssertNotNil(bannerImpression)
        let surveyButton = app.surveyBannerButton.wait()
        surveyButton.tap()
        app.webView.wait()
        let events =  await [snowplowMicro.getFirstEvent(with: "login.accountdelete.banner.exitsurvey.click"), snowplowMicro.getFirstEvent(with: "login.accountdelete.exitsurvey")]
        XCTAssertNotNil(events[0])
        XCTAssertNotNil(events[1])
    }

    func assertsError() {
        let alert = app.alert.wait()
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
        app.accountManagementView.deleteAccountButton.wait().tap()
    }
}
