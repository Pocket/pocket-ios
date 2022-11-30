// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class SearchTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    // MARK: - Saves: Search
    func test_enterSavesSearch_fromCarouselGoIntoSearch() {
        app.launch()
        tapSearch()
        XCTAssertTrue(app.navigationBar.buttons["Saves"].isSelected)
    }

    func test_enterSavesSearch_fromSwipeDownSearch() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.element.swipeDown()

        app.navigationBar.searchFields["Search"].wait().tap()
        XCTAssertTrue(app.navigationBar.buttons["Saves"].isSelected)
    }

    func test_searchSaves_forFreeUser_showsEmptyStateView() {
        server.routes.post("/graphql") { request, _ in
            Response.saves("initial-list-free-user")
        }
        app.launch()
        tapSearch()
        XCTAssertTrue(app.saves.searchView.exists)
        XCTAssertTrue(app.saves.searchEmptyStateView(for: "search-empty-state").exists)
    }

    func test_search_forPremiumUser_showsRecentSaves() {
        app.launch()
        tapSearch()
        XCTAssertTrue(app.saves.searchView.exists)
        XCTAssertTrue(app.saves.searchEmptyStateView(for: "recent-search-empty-state").exists)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("search-term\n")
        app.navigationBar.buttons["Cancel"].tap()
        tapSearch()
        XCTAssertTrue(app.saves.searchView.recentSearchesView.exists)
    }

    // MARK: - Archives: Search
    func test_enterArchiveSearch_fromCarouselGoIntoSearch() {
        app.launch()
        tapSearch(fromArchive: true)
        XCTAssertTrue(app.navigationBar.buttons["Archive"].isSelected)
    }

    func test_enterArchiveSearch_fromSwipeDownSearch() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.element.swipeDown()

        app.navigationBar.searchFields["Search"].wait().tap()
        XCTAssertTrue(app.navigationBar.buttons["Archive"].isSelected)
    }

    func test_searchArchive_forFreeUser_showsEmptyStateView() {
        server.routes.post("/graphql") { request, _ in
            Response.saves("initial-list-free-user")
        }
        app.launch()
        tapSearch(fromArchive: true)
        XCTAssertTrue(app.saves.searchView.exists)
        XCTAssertTrue(app.saves.searchEmptyStateView(for: "search-empty-state").exists)
    }

    func test_searchArchive_forPremiumUser_showsRecentSaves() {
        app.launch()
        tapSearch(fromArchive: true)
        XCTAssertTrue(app.saves.searchView.exists)
        XCTAssertTrue(app.saves.searchEmptyStateView(for: "recent-search-empty-state").exists)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("search-term\n")
        app.navigationBar.buttons["Cancel"].tap()
        tapSearch(fromArchive: true)
        XCTAssertTrue(app.saves.searchView.recentSearchesView.exists)
    }

    private func tapSearch(fromArchive: Bool = false) {
        app.tabBar.savesButton.wait().tap()
        if fromArchive {
            app.saves.selectionSwitcher.archiveButton.wait().tap()
        }
        app.saves.filterButton(for: "Search").wait().tap()
    }
}
