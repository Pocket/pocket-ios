// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class SearchTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

        server = Application()

        stubGraphQLEndpoint(isPremium: false)

        try server.start()
    }

    override func tearDownWithError() throws {
        Task {
            await snowplowMicro.assertNoBadEvents()
        }
        try server.stop()
        app.terminate()
    }

    // MARK: - Saves: Search
    @MainActor
    func test_enterSavesSearch_fromCarouselGoIntoSearch() async {
        app.launch()
        tapSearch()

        XCTAssertTrue(app.navigationBar.buttons["Saves"].isSelected)

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
    }

    @MainActor
    func test_enterSavesSearch_fromSwipeDownSearch() async {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.element.swipeDown()

        app.navigationBar.searchFields["Search"].wait().tap()
        XCTAssertTrue(app.navigationBar.buttons["Saves"].isSelected)

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
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
        stubGraphQLEndpoint(isPremium: true)
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
    @MainActor
    func test_submitSearch_forFreeUser_withArchive_showsResults() async {
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")

        async let impression0 = snowplowMicro.getFirstEvent(with: "global-nav.search.impression", index: 0)
        async let impression1 = snowplowMicro.getFirstEvent(with: "global-nav.search.impression", index: 1)

        let impressions = await [impression0, impression1]

        impressions[0]!.getUIContext()!.assertHas(type: "card")
        impressions[0]!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
        impressions[1]!.getUIContext()!.assertHas(type: "card")
        impressions[1]!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "all_items")
    }

    @MainActor
    func test_switchingScopes_showsResultsWithCache() async {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")
        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)

        app.navigationBar.buttons["All items"].wait().tap()
        XCTAssertEqual(searchView.cells.count, 3)

        await snowplowMicro.assertBaselineSnowplowExpectation()
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
    func test_submitSearch_fromRecentSearch() async {
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.submit")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
    }

    // MARK: - Select a Search Item
    @MainActor
    func test_selectSearchItem_showsReaderView() async {
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        let searchView = app.saves.searchView.searchResultsView.wait()
        XCTAssertEqual(searchView.cells.count, 2)
        app.saves.searchView.searchItemCell(matching: "Item 1").tap()
        app.readerView.wait()
        app.readerView.cell(containing: "Commodo Consectetur Dapibus").wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.card.open")
        searchEvent!.getUIContext()!.assertHas(type: "card")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
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
                return Response.fallbackResponses(apiRequest: apiRequest)
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
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isForSearch(.saves) {
                return Response(status: .internalServerError)
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }
        app.launch()
        tapSearch()
        let searchField = app.navigationBar.searchFields["Search"].wait()
        searchField.tap()
        searchField.typeText("item\n")

        XCTAssertTrue(app.saves.searchView.hasBanner(with: "Limited search results"))
    }

    // MARK: Search Actions
    @MainActor
    func test_favoritingAndUnfavoritingAnItemFromSearch_showsFavoritedIcon() async {
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

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.favorite")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")

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

        let searchEvent2 = await snowplowMicro.getFirstEvent(with: "global-nav.search.unfavorite")
        searchEvent2!.getUIContext()!.assertHas(type: "button")
        searchEvent2!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent2!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_sharingAnItemFromSearch_presentsShareSheet() async {
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

        itemCell.shareButton.tap()

        app.shareSheet.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.share")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_addTagsFromSearch_showsAddTagsView() async {
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

        itemCell.overFlowMenu.tap()
        app.addTagsButton.wait().tap()
        app.addTagsView.wait()
        app.addTagsView.allTagsView.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.addTags")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_archivingAnItemFromSearch_removesItem() async {
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

        itemCell.overFlowMenu.tap()
        app.archiveButton.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.archive")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_unArchivingAnItemFromSearch_removesItem() async {
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

        itemCell.overFlowMenu.tap()
        app.reAddButton.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.unarchive")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "archive")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_deletingAnItemFromSearch_presentsOverflowMenu() async {
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

        itemCell.overFlowMenu.tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let searchEvent = await snowplowMicro.getFirstEvent(with: "global-nav.search.delete")
        searchEvent!.getUIContext()!.assertHas(type: "button")
        searchEvent!.getUIContext()!.assertHas(componentDetail: "saves")
        searchEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    // MARK: Pagination
    @MainActor
    func test_search_showsPagination() async {
        app.launch()
        tapSearch()
        let firstExpectRequest = expectation(description: "First request to the server")
        let secondExpectRequest = expectation(description: "Second request to the server")
        var count = 0
        server.routes.post("/graphql") { request, loop in
            count += 1
            if count == 1 {
                firstExpectRequest.fulfill()
                return Response.searchPagination()
            } else if count == 2 {
                secondExpectRequest.fulfill()
                return Response.searchPagination("search-list-page-2")
            } else {
                fatalError("Unexpected request")
            }
        }

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
        app.saves.filterButton(for: "Search").wait().tap()
    }
}

extension SearchTests {
    func stubGraphQLEndpoint(isPremium: Bool) {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isForSearch(.saves) {
                return Response.searchList(.saves)
            } else if apiRequest.isForSearch(.archive) {
                return Response.searchList(.archive)
            } else if apiRequest.isForSearch(.all) {
                return Response.searchList(.all)
            } else if apiRequest.isToDeleteAnItem {
                return Response.delete()
            } else if apiRequest.isForItemDetail {
                return Response.itemDetail()
            } else if apiRequest.isForUserDetails {
                if isPremium {
                    return Response.premiumUserDetails()
                } else {
                    return Response.userDetails()
                }
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }
    }
}
