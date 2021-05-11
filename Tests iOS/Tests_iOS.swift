// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class Tests_iOS: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPersistAuthToken() throws {
        let server = Application()

        server.routes.post("/v3/oauth/authorize") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content:
                """
                {
                    "access_token":"the-access-token",
                    "username":"test@example.com",
                    "account": {
                        "firstName":"test",
                        "lastName":"user"
                    }
                }
                """
            )
        }
        _ = try! server.start().wait()

        let app = XCUIApplication()
        app.launchEnvironment = [
            "POCKET_V3_BASE_URL": "http://localhost:8080"
        ]

        app.launchArguments = ["clearKeychain"]
        app.launch()

        app.textFields["email"].tap()
        app.typeText("test@example.com")

        app.secureTextFields["password"].tap()
        app.typeText("super-secret-password")
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Signed in!"].waitForExistence(timeout: 1.0))

        app.terminate()
        app.launchArguments = []
        app.launch()

        XCTAssertTrue(app.staticTexts["Signed in!"].exists)
    }
}
