// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class SignOutTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        app = PocketAppElement(app: XCUIApplication())
        server = Application()
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        await snowplowMicro.resetSnowplowEvents()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_tappingSignOutshowsLogin() async {
        app.launch()
        app.tabBar.settingsButton.wait().tap()
        tap_SignOut()

        let logoutRowTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings.logout")
        XCTAssertNotNil(logoutRowTappedEvent)

        let account = XCUIApplication()
        account.alerts["Are you sure?"].scrollViews.otherElements.buttons["Log Out"].wait().tap()
        XCTAssertTrue(app.loggedOutView.exists)

        let logoutConfirmedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings.logout-confirmed")
        XCTAssertNotNil(logoutConfirmedEvent)

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_tappingSignOutCancelshowsAccountsMenu() async {
        app.launch()
        app.tabBar.settingsButton.wait().tap()
        tap_SignOut()
        let account = XCUIApplication()
        account.alerts["Are you sure?"].scrollViews.otherElements.buttons["Cancel"].wait().tap()
        let cellCount = account.cells.count
        XCTAssertTrue(cellCount > 0)

        let logoutRowTappedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings.logout")
        XCTAssertNotNil(logoutRowTappedEvent)

        let logoutConfirmedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings.logout-confirmed")
        XCTAssertNil(logoutConfirmedEvent)

        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    func tap_SignOut() {
        app.settingsView.logOutButton.tap()
    }
}
