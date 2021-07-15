// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct SignInScreen {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func waitForExistence(timeout: TimeInterval = 1) -> Bool {
        emailField().waitForExistence(timeout: 1)
    }

    func emailField() -> XCUIElement {
        app.textFields["email"]
    }

    func passwordField() -> XCUIElement {
        app.secureTextFields["password"]
    }

    func signInButton() -> XCUIElement {
        app.buttons["Sign In"]
    }

    func signIn(email: String, password: String) {
        emailField().tap()
        app.typeText(email)

        passwordField().tap()
        app.typeText(password)

        signInButton().tap()
    }
}
