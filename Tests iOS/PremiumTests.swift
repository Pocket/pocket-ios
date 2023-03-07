// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import StoreKitTest

class PremiumTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false
        let session = try SKTestSession(configurationFileNamed: "Test_Subscriptions")
        session.disableDialogs = true
        session.clearTransactions()
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
    func test_tapGoPremiumShowsUpgradeView() async {
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeView()
    }

    @MainActor
    func test_tapDismiss_dismissPremiumView() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeView()
        // When
        app.premiumUpgradeView.dismissPremiumButton.wait().tap()
        // Then
        let dismissPremiumEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.dismiss")
        XCTAssertNotNil(dismissPremiumEvent)
        XCTAssertFalse(app.premiumUpgradeView.exists)
    }

    @MainActor
    func test_monthlyButtonTapped() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeView()
        // When
        app.premiumUpgradeView.premiumUpgradeMonthlyButton.wait().tap()
        // Then
        let monthlyButtonTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.monthly")
        XCTAssertNotNil(monthlyButtonTappedEvent)
    }

    @MainActor
    func test_annualButtonTapped() async {
        // Given
        configureFreeUser()
        app.launch()
        await loadPremiumUpgradeView()
        // When
        app.premiumUpgradeView.premiumUpgradeAnnualButton.wait().tap()
        // Then
        let monthlyButtonTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium.annual")
        XCTAssertNotNil(monthlyButtonTappedEvent)
    }

    @MainActor
    func configureFreeUser() {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }
    }

    @MainActor
    func loadPremiumUpgradeView() async {
        app.tabBar.settingsButton.wait().tap()
        XCTAssertTrue(app.settingsView.exists)

        let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        XCTAssertNotNil(settingsViewEvent)

        tap_GoPremium()
        XCTAssertTrue(app.premiumUpgradeView.exists)

        let premiumViewShownEvent = await snowplowMicro.getFirstEvent(with: "global-nav.premium")
        XCTAssertNotNil(premiumViewShownEvent)
    }

    func tap_GoPremium() {
        app.settingsView.goPremiumButton.tap()
    }
}
