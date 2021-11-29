// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails


class SignOutTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    func listResponse(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    func slateResponse() -> Response {
        Response {
            Status.ok
            Fixture.data(name: "slates")
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = PocketAppElement(app: XCUIApplication())
        server = Application()

        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                return self.listResponse()
            }
        }

        try server.start()
        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_tappingSignOutButton_sendsUserBackToSignInScreen() {
        app.tabBar.settingsButton.wait().tap()
        app.settingsView.signOutButton.wait().tap()

        app.signInView.emailField.wait()
    }
}
