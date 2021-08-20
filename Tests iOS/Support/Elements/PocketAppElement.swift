// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct PocketAppElement {
    static let defaultEnvironment = [
        "POCKET_V3_BASE_URL": "http://localhost:8080",
        "POCKET_CLIENT_API_URL": "http://localhost:8080/graphql"
    ]

    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var isRunningInForeground: Bool {
        app.state == .runningForeground
    }

    var signInView: SignInFormElement {
        return SignInFormElement(app)
    }

    var userListView: UserListElement {
        return UserListElement(app.tables["user-list"])
    }

    var readerView: ReaderElement {
        return ReaderElement(app)
    }

    var webReaderView: WebReaderElement {
        return WebReaderElement(app.webViews.element(boundBy: 0))
    }

    var shareSheet: XCUIElement {
        return app.otherElements["ActivityListView"]
    }

    var favoriteButton: XCUIElement {
        app.buttons["Favorite"]
    }

    var unfavoriteButton: XCUIElement {
        app.buttons["Unfavorite"]
    }

    var deleteButton: XCUIElement {
        app.buttons["Delete"]
    }

    var archiveButton: XCUIElement {
        app.buttons["Archive"]
    }

    var shareButton: XCUIElement {
        app.buttons["Share"]
    }

    @discardableResult
    func launch(
        arguments: [String] = [],
        environment: [String: String] = [:]
    ) -> PocketAppElement {
        app.launchArguments = arguments + ["disableSentry"]
        app.launchEnvironment = PocketAppElement
            .defaultEnvironment
            .merging(environment) { key, _ in key }

        app.launch()

        return self
    }

    func terminate() {
        app.terminate()
    }

    func typeText(_ text: String) {
        app.typeText(text)
    }
}
