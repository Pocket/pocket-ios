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

    var loggedOutView: XCUIElement {
        return app.collectionViews["logged-out"]
    }

    var bannerView: XCUIElement {
        return app.otherElements["banner"]
    }

    var homeView: HomeViewElement {
        return HomeViewElement(app.otherElements["home"])
    }

    var myListView: MyListElement {
        return MyListElement(app)
    }

    var accountView: AccountViewElement {
        return AccountViewElement(app.collectionViews["account"])
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
        let query: XCUIElementQuery
        if #available(iOS 16, *) {
            query = app.collectionViews
        } else {
            query = app.tables
        }

        return ReportViewElement(query["report-recommendation"])
    }

    var sortMenu: SortMenuElement {
        return SortMenuElement(app.tables["sort-menu"])
    }

    var shareSheet: XCUIElement {
        return app.otherElements["ActivityListView"]
    }

    var tabBar: TabBarElement {
        return TabBarElement(app.tabBars.element(boundBy: 0))
    }

    var addTagsView: AddTagsViewElement {
        return AddTagsViewElement(app.otherElements["add-tags"])
    }

    var favoriteButton: XCUIElement {
        app.buttons["Favorite"]
    }

    var unfavoriteButton: XCUIElement {
        app.buttons["Unfavorite"]
    }

    var deleteButton: XCUIElement {
        app.buttons["item-action-delete"]
    }

    var archiveButton: XCUIElement {
        app.buttons["item-action-archive"]
    }

    var addTagsButton: XCUIElement {
        app.buttons["item-action-add-tags"]
    }

    var reAddButton: XCUIElement {
        app.buttons["item-action-move-to-my-list"]
    }

    var shareButton: XCUIElement {
        app.buttons["Share"]
    }

    var reportButton: XCUIElement {
        app.buttons["Report"]
    }

    var alert: AlertElement {
        AlertElement(app.alerts.element(boundBy: 0))
    }

    var navigationBar: XCUIElement {
        app.navigationBars.element(boundBy: 0)
    }

    @discardableResult
    func launch(
        arguments: LaunchArguments = .bypassSignIn,
        environment: LaunchEnvironment = .withSession
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

    func activate() {
        app.activate()
    }
}
