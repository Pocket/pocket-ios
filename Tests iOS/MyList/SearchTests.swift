// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO
import Apollo
import ApolloAPI
import ApolloTestSupport
import PocketGraphTestMocks

class SearchTests: PocketXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        stubGraphQLEndpoint(isPremium: false)
    }

    // MARK: - Saves: Search
    @MainActor
    func test_enterSavesSearch_fromSwipeDownSearch() async {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.element.swipeDown()

        app.navigationBar.searchFields["Search"].wait().tap()
        XCTAssertTrue(app.navigationBar.buttons["Saves"].isSelected)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
    }

    func test_searchSaves_forFreeUser_showsEmptyStateView() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves("initial-list-free-user")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        tapSearch()
        XCTAssertTrue(app.saves.searchView.exists)
        XCTAssertTrue(app.saves.searchEmptyStateView(for: "search-empty-state").exists)
    }

    func test_search_forPremiumUser_showsRecentSaves() {
        stubGraphQLEndpoint(isPremium: true)
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

    func test_enterArchiveSearch_fromSwipeDownSearch() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.element.swipeDown()

        app.navigationBar.searchFields["Search"].wait().tap()
        XCTAssertTrue(app.navigationBar.buttons["Archive"].isSelected)
    }

    func test_searchArchive_forFreeUser_showsEmptyStateView() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves("initial-list-free-user")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        tapSearch(fromArchive: true)
        app.saves.searchView.wait()
        app.saves.searchEmptyStateView(for: "search-empty-state").wait()
    }

    func test_searchArchive_forPremiumUser_showsRecentSaves() {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch(fromArchive: true)
        app.saves.searchView.wait()
        app.saves.searchEmptyStateView(for: "recent-search-empty-state").wait()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("search-term\n")
        app.navigationBar.buttons["Cancel"].tap()
        tapSearch(fromArchive: true)
        XCTAssertTrue(app.saves.searchView.recentSearchesView.exists)
    }

    // MARK: - Online Search
    @MainActor
    func test_submitSearch_forFreeUser_withArchive_showsResults() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves("initial-list-free-user")
            } else if apiRequest.isForSearch(.archive) {
                return Response.searchList(.archive)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 1)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "archive")
    }

    @MainActor
    func test_submitSearch_forPremiumUser_withSaves_showsResults() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")

        async let impression0 = snowplowMicro.getFirstEvent(with: "global-nav.search.impression", index: 0)
        async let impression1 = snowplowMicro.getFirstEvent(with: "global-nav.search.impression", index: 1)

        let impressions = await [impression0, impression1]

        impressions[0]!.getUIContext()!.assertHas(type: "card")
        impressions[0]!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
        impressions[1]!.getUIContext()!.assertHas(type: "card")
        impressions[1]!.getContentContext()!.assertHas(url: "http://localhost:8080/hello-2")
    }

    @MainActor
    func test_submitSearch_forPremiumUser_withArchive_showsResults() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 1)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "archive")
    }

    @MainActor
    func test_submitSearch_forPremiumUser_withAllItems_showsResults() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()
        app.navigationBar.buttons["All items"].wait().tap()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 3)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "all_items")
    }

    @MainActor
    func test_switchingScopes_forPremiumUser_showsResultsWithCache() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)

        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 3)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.switchscope")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "all_items")

        app.navigationBar.buttons["Archive"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 1)

        let searchEvent2 = await snowplowMicro.getFirstEvent(with: "global-nav.search.switchscope")
        searchEvent2!.getUIContext()!.assertHas(type: "button")
        searchEvent2!.getUIContext()!.assertHas(componentDetail: "archive")

        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 3)

        let searchEvent3 = await snowplowMicro.getFirstEvent(with: "global-nav.search.switchscope")
        searchEvent3!.getUIContext()!.assertHas(type: "button")
        searchEvent3!.getUIContext()!.assertHas(componentDetail: "all_items")

        app.navigationBar.buttons["Archive"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 1)

        let searchEvent4 = await snowplowMicro.getFirstEvent(with: "global-nav.search.switchscope")
        searchEvent4!.getUIContext()!.assertHas(type: "button")
        searchEvent4!.getUIContext()!.assertHas(componentDetail: "archive")
    }

    // MARK: - Recent Search
    @MainActor
    func test_submitSearch_forPremiumUser_fromRecentSearch() async {
        stubGraphQLEndpoint(isPremium: true)
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

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
    }

    // MARK: - Select a Search Item
    @MainActor
    func test_selectSearchItem_forPremiumUser_showsReaderView() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        let searchView = app.saves.searchView.searchResultsView.wait()
        app.saves.searchView.searchItemCell(matching: "Item 1").wait()
        XCTAssertEqual(searchView.cells.count, 2)
        app.saves.searchView.searchItemCell(matching: "Item 1").wait().tap()
        app.readerView.wait()
        app.readerView.cell(containing: "Commodo Consectetur Dapibus").wait()

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.card.open")
        searchEvent!.getUIContext()!.assertHas(type: "card")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    // MARK: - Search Loading State
    func test_search_forPremiumUser_showsSkeletonView() {
        continueAfterFailure = true
        var savesPromise: EventLoopPromise<Response>?
        let searchSavesExpectation = expectation(description: "did search saves")

        searchSavesExpectation.assertForOverFulfill = false
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSearch(.saves) {
                defer { searchSavesExpectation.fulfill() }
                savesPromise = eventLoop.makePromise(of: Response.self)
                return savesPromise!.futureResult
            } else if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        app.saves.searchView.skeletonView.wait()

        savesPromise!.completeWith(.success(.searchList(.saves)))
        wait(for: [searchSavesExpectation])
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)
    }

    // MARK: - Search Error State
    func test_search_showsErrorView() {
        server.routes.post("/graphql") { request, eventLoop -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSearch(.archive) {
                return Response(status: .internalServerError)
            }

            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        tapSearch(fromArchive: true)
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchEmptyStateView(for: "error-empty-state").wait()
    }

    func test_search_forSaves_forPremiumUser_showsErrorBanner() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSearch(.saves) {
                return Response(status: .internalServerError)
            } else if apiRequest.isForUserDetails {
                return .premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        XCTAssertTrue(app.saves.searchView.hasBanner(with: "Limited search results"))
        // TODO: Fix tests after addressing issue with other server error banner
//        app.saves.searchView.banner(with: "Send a report").tap()
//        openReportIssueView()
    }

    private func openReportIssueView() {
        let reportIssueView = app.reportIssueView.wait()
        reportIssueView.nameField.wait().tap()
        reportIssueView.nameField.wait().typeText("First Last")
        reportIssueView.commentSection.wait().tap()
        reportIssueView.commentSection.wait().typeText("An error has occurred when searching")
        XCTAssertEqual(reportIssueView.nameField.value as! String, "First Last")
        XCTAssertEqual(reportIssueView.commentSection.value as! String, "An error has occurred when searching")
    }

    // MARK: Search Actions
    @MainActor
    func test_favoritingAndUnfavoritingAnItemFromSearch_forPremiumUser_showsFavoritedIcon() async {
        let favoriteExpectation = expectation(description: "A request to the server")
        let unfavoriteExpectation = expectation(description: "A request to the server")

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSearch(.saves) {
                return .searchList(.saves)
            } else if apiRequest.isForSearch(.archive) {
                return .searchList(.archive)
            } else if apiRequest.isForSearch(.all) {
                return .searchList(.all)
            } else if apiRequest.isForUserDetails {
                return .premiumUserDetails()
            } else if apiRequest.isToFavoriteAnItem {
                defer { favoriteExpectation.fulfill() }
                return .favorite(apiRequest: apiRequest)
            } else if apiRequest.isToUnfavoriteAnItem {
                defer { unfavoriteExpectation.fulfill() }
                return .unfavorite(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(matching: "Item 2")
            .wait()

        itemCell.favoriteButton.wait().tap()
        wait(for: [favoriteExpectation])
        XCTAssertTrue(itemCell.favoriteButton.isFilled)

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.favorite")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello-2")

        itemCell.favoriteButton.wait().tap()
        wait(for: [unfavoriteExpectation])
        XCTAssertFalse(itemCell.favoriteButton.isFilled)

        let searchEvent2 = await snowplowMicro.getFirstEvent(with: "global-nav.search.unfavorite")
        searchEvent2!.getUIContext()!.assertHas(type: "button")
        searchEvent2!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent2!.getContentContext()!.assertHas(url: "http://localhost:8080/hello-2")
    }

    @MainActor
    func test_addTagsFromSearch_forPremiumUser_showsAddTagsView() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(matching: "Item 1")
            .wait()

        itemCell.overFlowMenu.wait().tap()
        app.addTagsButton.wait().tap()

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.addTags")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_archivingAnItemFromSearch_forPremiumUser_removesItem() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(matching: "Item 1")
            .wait()

        itemCell.overFlowMenu.wait().tap()
        app.archiveButton.wait().tap()

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.archive")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_unArchivingAnItemFromSearch_forPremiumUser_removesItem() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch(fromArchive: true)

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(matching: "Item 3")
            .wait()

        itemCell.overFlowMenu.wait().tap()
        app.reAddButton.wait().tap()

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.unarchive")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "archive")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_deletingAnItemFromSearch_forPremiumUser_presentsOverflowMenu() async {
        stubGraphQLEndpoint(isPremium: true)
        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        app.saves.searchView.searchResultsView.wait()

        let itemCell = app
            .saves.searchView
            .searchItemCell(matching: "Item 2")
            .wait()

        itemCell.overFlowMenu.wait().tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()

        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.delete")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello-2")
    }

    // MARK: Pagination
    @MainActor
    func test_search_forPremiumUser_showsPagination() async {
        let firstExpectRequest = expectation(description: "First request to the server")
        let secondExpectRequest = expectation(description: "Second request to the server")
        var searchCount = 0
        server.routes.post("/graphql") { request, loop -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSearch(.saves) {
                defer {searchCount += 1}
                switch searchCount {
                case 0:
                    defer { firstExpectRequest.fulfill() }
                    return .searchPagination()
                default:
                    defer { secondExpectRequest.fulfill() }
                    return .searchPagination("search-list-page-2")
                }
            } else if apiRequest.isForUserDetails {
                return .premiumUserDetails()
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
        tapSearch()

        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        app.saves.searchView.searchResultsView.wait()
        app.saves.searchView.searchItemCell(matching: "Item 4").wait().element.swipeUp(velocity: .fast)
        app.saves.searchView.searchItemCell(matching: "Item 9").wait().element.swipeUp(velocity: .fast)
        app.saves.searchView.searchItemCell(matching: "Item 13").wait().element.swipeUp(velocity: .fast)
        app.saves.searchView.searchItemCell(matching: "Item 20").wait().element.swipeUp(velocity: .fast)
        app.saves.searchView.searchItemCell(matching: "Item 26").wait().element.swipeUp(velocity: .fast)

        wait(for: [firstExpectRequest, secondExpectRequest])

        await snowplowMicro.assertBaselineSnowplowExpectation()

        async let event0 = snowplowMicro.getFirstEvent(with: "global-nav.search.searchPage", index: 1)
        async let event1 = snowplowMicro.getFirstEvent(with: "global-nav.search.searchPage", index: 2)

        let events = await [event0, event1]

        events[0]!.getUIContext()!.assertHas(type: "page")
        events[0]!.getUIContext()!.assertHas(componentDetail: "saves")

        events[1]!.getUIContext()!.assertHas(type: "page")
        events[1]!.getUIContext()!.assertHas(componentDetail: "saves")
    }

    private func tapSearch(fromArchive: Bool = false) {
        app.tabBar.savesButton.wait().tap()
        if fromArchive {
            app.saves.selectionSwitcher.archiveButton.wait().tap()
        }
        app.navigationBar.searchFields["Search"].wait().tap()
    }
}

extension SearchTests {
    func stubGraphQLEndpoint(isPremium: Bool) {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSearch(.saves) {
                return .searchList(.saves)
            } else if apiRequest.isForSearch(.archive) {
                return .searchList(.archive)
            } else if apiRequest.isForSearch(.all) {
                return .searchList(.all)
            } else if apiRequest.isForUserDetails {
                if isPremium {
                    return .premiumUserDetails()
                } else {
                    return .userDetails()
                }
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }
    }
}
