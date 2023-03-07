// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class PremiumTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    //var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        app = PocketAppElement(app: XCUIApplication())
        server = Application()

        //await snowplowMicro.resetSnowplowEvents()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_tappingGoPremiumShowsUpgradeView_freeUser() async {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return Response.freeUserSaves()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        await loadPremiumUpgradeView()
    }

    @MainActor
    func loadPremiumUpgradeView() async {
        app.tabBar.settingsButton.wait().tap()
        XCTAssertTrue(app.settingsView.exists)

        //let settingsViewEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings")
        //XCTAssertNotNil(settingsViewEvent)

        tap_GoPremium()

        XCTAssertTrue(app.premiumUpgradeView.exists)
    }

    func tap_GoPremium() {
        app.settingsView.goPremiumButton.tap()
    }
}
