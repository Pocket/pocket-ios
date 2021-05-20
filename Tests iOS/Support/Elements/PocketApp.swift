// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct PocketApp {
    static let defaultEnvironment = [
        "POCKET_V3_BASE_URL": "http://localhost:8080",
        "POCKET_CLIENT_API_URL": "http://localhost:8080"
    ]

    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var isRunningInForeground: Bool {
        app.state == .runningForeground
    }

    func launch(
        arguments: [String] = [],
        environment: [String: String] = PocketApp.defaultEnvironment
    ) {
        app.launchArguments = arguments
        app.launchEnvironment = environment

        app.launch()
    }

    func terminate() {
        app.terminate()
    }

    func signInView() -> SignInScreen {
        return SignInScreen(app: app)
    }

    func userListView() -> UserListScreen {
        return UserListScreen(el: app.tables["user-list"])
    }

    func webReaderView() -> WebReaderScreen {
        return WebReaderScreen(el: app.webViews.element(boundBy: 0))
    }
}
