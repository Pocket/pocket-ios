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

    var surveyBannerButton: XCUIElement {
        // Some reason the banner view when used on Logout does not keep its accessibility identifiers...
        return app.buttons.element(matching: NSPredicate(format: "label == %@", "Quick survey"))
    }

    /// Gets the delete overlay view, for some reason this is in the main app element.
    var deletingAccountOverlay: XCUIElement {
        return app.otherElements["loading-view"]
    }

    var homeView: HomeViewElement {
        return HomeViewElement(app.otherElements["home"])
    }

    var saves: SavesElement {
        return SavesElement(app)
    }

    var settingsView: SettingsViewElement {
        return SettingsViewElement(app.collectionViews["settings"])
    }

    var premiumUpgradeView: PremiumUpgradeViewElement {
        PremiumUpgradeViewElement(app.otherElements["premium-upgrade-view"])
    }

    var searchGetPremiumEmptyView: SearchGetPremiumEmptyViewElement {
        SearchGetPremiumEmptyViewElement(app.otherElements["get-premium-empty-state"])
    }

    var accountManagementView: AccountManagementViewElement {
        return AccountManagementViewElement(app.collectionViews["account-management"])
    }

    var deleteConfirmationView: DeleteConfirmationViewElement {
        return DeleteConfirmationViewElement(app.otherElements["delete-confirmation"])
    }

    var premiumStatusView: PremiumStatusViewElement {
        return PremiumStatusViewElement(app.otherElements["premium-status-view"])
    }

    var slateDetailView: SlateDetailElement {
        return SlateDetailElement(app.otherElements["slate-detail"])
    }

    var readerView: ReaderElement {
        return ReaderElement(app)
    }

    var collectionView: CollectionElement {
        return CollectionElement(app)
    }

    var webView: XCUIElement {
       return app.webViews.element(boundBy: 0)
    }

    var webReaderView: WebReaderElement {
        return WebReaderElement(app.webViews.element(boundBy: 0))
    }

    var reportView: ReportViewElement {
        let query: XCUIElementQuery
        query = app.collectionViews

        return ReportViewElement(query["report-recommendation"])
    }

    var reportIssueView: ReportIssueViewElement {
        let query: XCUIElementQuery
        query = app.collectionViews

        return ReportIssueViewElement(query["report-issue"])
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

    var readerActionWebActivity: ReaderActionsWebActivityElement {
        return ReaderActionsWebActivityElement(app.otherElements["ActivityListView"])
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
        app.buttons["item-action-move-to-saves"]
    }

    var shareButton: XCUIElement {
        app.buttons["Share"]
    }

    var reportButton: XCUIElement {
        app.buttons["Report"]
    }

    var reportIssueButton: XCUIElement {
        app.buttons["get-report-issue-button"]
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

    @discardableResult
    func waitForHomeToLoad() -> HomeViewElement {
        self.homeView.savedItemCell("Item 1").wait()
        self.homeView.recommendationCell("Slate 1, Recommendation 1").wait()
        return self.homeView
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

/// Listen
/// Hacky helper extenstion until we add accessibility identifier helpers to Listen
extension PocketAppElement {
    var listenPlay: XCUIElement {
        app.buttons["Play"]
    }

    /// Once listen is visible. its the first collection view that has articles
    var listenList: XCUIElement {
        app.collectionViews.element(boundBy: 0)
    }
}
