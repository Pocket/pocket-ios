// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import StoreKitTest

// swiftlint:disable force_try
class PremiumTests: PocketXCTestCase {
    var storeSession: SKTestSession!

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        storeSession = try SKTestSession(configurationFileNamed: "Test_Subscriptions")
        storeSession.resetToDefaultState()
        storeSession.clearTransactions()
        storeSession.disableDialogs = true
    }

    /// Test that tapping "Go Premium" in Settings presents the Premium Upgrade view
    @MainActor
    func test_tapSettingsUpsellShowsUpgradeView() async {
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_tapSearchPremiumUpsellShowsUpgradeView() async {
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSearch()
    }

    /// Test that Premium Upgrade view dismisses when tapping the dismiss button
    @MainActor
    func test_tapDismissDismissPremiumView() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        // When
        app.premiumUpgradeView.dismissPremiumButton.wait().tap()
        // Then
        let dismissPremiumEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.dismiss")
        XCTAssertNotNil(dismissPremiumEvent)
        XCTAssertFalse(app.premiumUpgradeView.exists)
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Test that monthly button tapped triggers the right event
    @MainActor
    func test_monthlyButtonTapped() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        // When
        app.premiumUpgradeView.premiumUpgradeMonthlyButton.wait().tap()
        // Then
        let monthlyButtonTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.monthly")
        XCTAssertNotNil(monthlyButtonTappedEvent)
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Test that annual button tapped triggers the right event
    @MainActor
    func test_annualButtonTapped() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        // When
        app.premiumUpgradeView.premiumUpgradeAnnualButton.wait().tap()
        // Then
        let monthlyButtonTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.annual")
        XCTAssertNotNil(monthlyButtonTappedEvent)
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Test that purchase monthly subscription succeeds
    @MainActor
    func test_purchaseMonthlySubscriptionSuccess() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        // When
        try! storeSession.buyProduct(productIdentifier: "monthly.subscription.pocket")
        // Then
        let purchaseSuccessEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.purchase.success")
        XCTAssertNotNil(purchaseSuccessEvent)

        purchaseSuccessEvent!.getUIContext()!.assertHas(type: "dialog")
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Test that purchase annual subscription succeeds
    @MainActor
    func test_purchaseAnnualSubscriptionSuccess() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeViewFromSettings()
        // When
        try! storeSession.buyProduct(productIdentifier: "annual.subscription.pocket")
        // Then
        let purchaseSuccessEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.purchase.success")
        XCTAssertNotNil(purchaseSuccessEvent)

        purchaseSuccessEvent!.getUIContext()!.assertHas(type: "dialog")
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    /// Set user to free
    @MainActor
    private func configureFreeUser() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .freeUserSaves()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    /// Load premium upgrade view from Settings
    @MainActor
    private func loadPremiumUpgradeViewFromSettings() async {
        app.tabBar.settingsButton.wait().tap()
        XCTAssertTrue(app.settingsView.exists)

        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        XCTAssertNotNil(settingsViewEvent)

        let goPremiumButtonImpression = await snowplowMicro.getFirstEvent(with: "account.premium.upsell")
        XCTAssertNotNil(goPremiumButtonImpression)

        goPremiumButtonImpression!.getUIContext()!.assertHas(type: "button")

        app.settingsView.goPremiumButton.tap()
        XCTAssertTrue(app.premiumUpgradeView.exists)

        let premiumViewShownEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium")
        XCTAssertNotNil(premiumViewShownEvent)
    }

    /// Load premium upgrade view from Saves > Search > All Items
    @MainActor
    private func loadPremiumUpgradeViewFromSearch() async {
        app.tabBar.savesButton.wait().tap()
        app.saves.element.swipeDown()
        app.navigationBar.searchFields["Search"].wait().tap()
        app.navigationBar.searchFields["Search"].typeText("\n")
        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertTrue(app.searchGetPremiumEmptyView.exists)

        let goPremiumButtonImpression = await snowplowMicro.getFirstEvent(with: "global-nav.search.premium.upsell")
        XCTAssertNotNil(goPremiumButtonImpression)

        goPremiumButtonImpression!.getUIContext()!.assertHas(type: "button")

        app.searchGetPremiumEmptyView.getPocketPremiumButton.tap()
        XCTAssertTrue(app.premiumUpgradeView.exists)

        let searchUpsellEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.premium.upsell")
        XCTAssertNotNil(searchUpsellEvent)
    }
}
// swiftlint:enable force_try
