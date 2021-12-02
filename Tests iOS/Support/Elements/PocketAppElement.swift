// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct PocketAppElement {
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

    var homeView: HomeViewElement {
        return HomeViewElement(app.otherElements["home"])
    }

    var userListView: UserListElement {
        return UserListElement(app.tables["user-list"])
    }

    var settingsView: SettingsViewElement {
        return SettingsViewElement(app.collectionViews["settings"])
    }

    var slateDetailView: SlateDetailElement {
        return SlateDetailElement(app.otherElements["slate-detail"])
    }

    var readerView: ReaderElement {
        return ReaderElement(app)
    }

    var webReaderView: WebReaderElement {
        return WebReaderElement(app.webViews.element(boundBy: 0))
    }
    
    var reportView: ReportViewElement {
        return ReportViewElement(app.tables["report-recommendation"])
    }

    var shareSheet: XCUIElement {
        return app.otherElements["ActivityListView"]
    }

    var tabBar: TabBarElement {
        return TabBarElement(app.tabBars.element(boundBy: 0))
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
        arguments: LaunchArguments = LaunchArguments(),
        environment: LaunchEnvironment = LaunchEnvironment()
    ) -> PocketAppElement {
        app.launchArguments = arguments.toArray()
        app.launchEnvironment = environment.toDictionary()

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
