// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

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
            } else if apiRequest.isForSearch(.saves) {
                return Response.searchList(.saves)
            } else if apiRequest.isForSearch(.archive) {
                return Response.searchList(.archive)
            } else if apiRequest.isForSearch(.all) {
                return Response.searchList(.all)
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

    // MARK: - Online Search
    func test_submitSearch_forFreeUser_withArchive_showsResults() {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSearch(.archive) {
                return Response.searchList(.archive)
            } else {
                return Response.saves("initial-list-free-user")
            }
        }
        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 1)
    }

    func test_submitSearch_forPremiumUser_withSaves_showsResults() {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)
    }

    func test_submitSearch_forPremiumUser_withArchive_showsResults() {
        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 1)
    }

    func test_submitSearch_forPremiumUser_withAllItems_showsResults() {
        app.launch()
        tapSearch()
        app.navigationBar.buttons["All items"].wait().tap()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 3)
    }

    func test_switchingScopes_showsResultsWithCache() {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)

        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 3)

        app.navigationBar.buttons["Archive"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 1)

        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 3)

        app.navigationBar.buttons["Archive"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 1)
    }

    // MARK: - Recent Search
    func test_submitSearch_fromRecentSearch() {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        var searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)

        app.navigationBar.buttons["Cancel"].tap()

        searchField.tap()
        searchField.typeText("test\n")
        searchView = app.saves.searchView.searchResultsView.wait()

        app.navigationBar.buttons["Cancel"].tap()
        XCTAssertTrue(app.saves.itemView(at: 0).element.isHittable)

        searchField.tap()
        app.saves.searchView.recentSearchesView.staticTexts["item"].tap()
        XCTAssertEqual(searchView.cells.count, 2)
        XCTAssertFalse(app.saves.itemView(at: 0).element.isHittable)
    }

    // MARK: - Select a Search Item
    func test_selectSearchItem_showsReaderView() {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)
        app.saves.searchView.searchItemCell(at: 0).tap()
        app.readerView.wait()
        app.readerView.cell(containing: "Commodo Consectetur Dapibus").wait()
    }

    // MARK: - Search Loading State
    func test_search_showsSkeletonView() {
        continueAfterFailure = true
        var promises: [EventLoopPromise<Response>] = []

        server.routes.post("/graphql") { request, eventLoop in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForSearch(.saves) {
                let promise = eventLoop.makePromise(of: Response.self)
                promises.append(promise)
                return promise.futureResult
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        app.saves.searchView.skeletonView.wait()

        promises[0].completeWith(.success(Response.searchList(.saves)))

        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)
    }

    // MARK: - Search Error State
    func test_search_showsErrorView() {
        server.routes.post("/graphql") { request, _ in
            Response(status: .internalServerError)
        }
        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        XCTAssertTrue(app.saves.searchEmptyStateView(for: "error-empty-state").exists)
    }

    func test_search_forSaves_showsErrorBanner() {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isForSearch(.saves) {
                return Response(status: .internalServerError)
            } else {
                fatalError("Unexpected request")
            }
        }
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        XCTAssertTrue(app.saves.searchView.hasBanner(with: "Limited search results"))
    }

    func test_favoritingAndUnfavoritingAnItemFromSearch_showsFavoritedIcon() {
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(at: 1)
            .wait()

        let expectRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToFavoriteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.favorite()
        }

        itemCell.favoriteButton.tap()
        wait(for: [expectRequest])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        let expectUnfavoriteRequest = expectation(description: "A request to the server")
        server.routes.post("/graphql") { request, loop in
            defer { expectUnfavoriteRequest.fulfill() }
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToUnfavoriteAnItem)
            XCTAssertTrue(apiRequest.contains("item-2"))

            return Response.unfavorite()
        }

        itemCell.favoriteButton.tap()
        wait(for: [expectUnfavoriteRequest])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)
    }

    func test_sharingAnItemFromSearch_presentsShareSheet() {
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(at: 1)
            .wait()

        itemCell.shareButton.tap()

        app.shareSheet.wait()
    }

    private func tapSearch(fromArchive: Bool = false) {
        app.tabBar.savesButton.wait().tap()
        if fromArchive {
            app.saves.selectionSwitcher.archiveButton.wait().tap()
        }
        app.saves.filterButton(for: "Search").wait().tap()
    }
}
