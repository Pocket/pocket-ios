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
        return app.collectionViews["logged-out"].wait()
    }

    var bannerView: XCUIElement {
        return app.otherElements["banner"].wait()
    }

    var surveyBannerButton: XCUIElement {
        // Some reason the banner view when used on Logout does not keep its accessibility identifiers...
        return app.buttons.element(matching: NSPredicate(format: "label == %@", "Quick survey")).wait()
    }

    /// Gets the delete overlay view, for some reason this is in the main app element.
    var deletingAccountOverlay: XCUIElement {
        return app.otherElements["deleting-overlay"].wait()
    }

    var homeView: HomeViewElement {
        return HomeViewElement(app.otherElements["home"].wait())
    }

    var saves: SavesElement {
        return SavesElement(app)
    }

    var settingsView: SettingsViewElement {
        return SettingsViewElement(app.collectionViews["settings"].wait())
    }

    var premiumUpgradeView: PremiumUpgradeViewElement {
        PremiumUpgradeViewElement(app.otherElements["premium-upgrade-view"].wait())
    }

    var searchGetPremiumEmptyView: SearchGetPremiumEmptyViewElement {
        SearchGetPremiumEmptyViewElement(app.otherElements["get-premium-empty-state"].wait())
    }

    var accountManagementView: AccountManagementViewElement {
        return AccountManagementViewElement(app.collectionViews["account-management"].wait())
    }

    var deleteConfirmationView: DeleteConfirmationViewElement {
        return DeleteConfirmationViewElement(app.otherElements["delete-confirmation"].wait())
    }

    var premiumStatusView: PremiumStatusViewElement {
        return PremiumStatusViewElement(app.otherElements["premium-status-view"].wait())
    }

    var slateDetailView: SlateDetailElement {
        return SlateDetailElement(app.otherElements["slate-detail"].wait())
    }

    var readerView: ReaderElement {
        return ReaderElement(app)
    }

    var webView: XCUIElement {
       return app.webViews.element(boundBy: 0).wait()
    }

    var webReaderView: WebReaderElement {
        return WebReaderElement(app.webViews.element(boundBy: 0).wait())
    }

    var reportView: ReportViewElement {
        let query: XCUIElementQuery
        if #available(iOS 16, *) {
            query = app.collectionViews
        } else {
            query = app.tables
        }

        return ReportViewElement(query["report-recommendation"].wait())
    }

    var sortMenu: SortMenuElement {
        return SortMenuElement(app.tables["sort-menu"].wait())
    }

    var shareSheet: XCUIElement {
        return app.otherElements["ActivityListView"].wait()
    }

    var tabBar: TabBarElement {
        return TabBarElement(app.tabBars.element(boundBy: 0).wait())
    }

    var addTagsView: AddTagsViewElement {
        return AddTagsViewElement(app.otherElements["add-tags"].wait())
    }

    var readerActionWebActivity: ReaderActionsWebActivityElement {
        return ReaderActionsWebActivityElement(app.otherElements["ActivityListView"].wait())
    }

    var favoriteButton: XCUIElement {
        app.buttons["Favorite"].wait()
    }

    var unfavoriteButton: XCUIElement {
        app.buttons["Unfavorite"].wait()
    }

    var deleteButton: XCUIElement {
        app.buttons["item-action-delete"].wait()
    }

    var archiveButton: XCUIElement {
        app.buttons["item-action-archive"].wait()
    }

    var addTagsButton: XCUIElement {
        app.buttons["item-action-add-tags"].wait()
    }

    var reAddButton: XCUIElement {
        app.buttons["item-action-move-to-saves"].wait()
    }

    var shareButton: XCUIElement {
        app.buttons["Share"].wait()
    }

    var reportButton: XCUIElement {
        app.buttons["Report"].wait()
    }

    var alert: AlertElement {
        AlertElement(app.alerts.element(boundBy: 0).wait())
    }

    var navigationBar: XCUIElement {
        app.navigationBars.element(boundBy: 0).wait()
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
