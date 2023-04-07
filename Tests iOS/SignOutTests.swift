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
        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        await snowplowMicro.resetSnowplowEvents()
        try server.start()
    }

    @MainActor
    override func tearDown() async throws {
        try server.stop()
        app.terminate()
        await snowplowMicro.assertBaselineSnowplowExpectation()
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
        app.loggedOutView.wait()

        let logoutConfirmedEvent = await snowplowMicro.getFirstEvent(with: "global-nav.settings.logout-confirmed")
        XCTAssertNotNil(logoutConfirmedEvent)
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

        let events = await [snowplowMicro.getFirstEvent(with: "global-nav.settings.logout"), snowplowMicro.getFirstEvent(with: "global-nav.settings.logout-confirmed")]

        let logoutRowTappedEvent = events[0]
        XCTAssertNotNil(logoutRowTappedEvent)

        let logoutConfirmedEvent = events[1]
        XCTAssertNil(logoutConfirmedEvent)
    }

    func tap_SignOut() {
        app.settingsView.logOutButton.tap()
    }
}
