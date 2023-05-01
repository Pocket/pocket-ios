// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class HomeTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

        server = Application()

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSavesContent {
                return .saves("initial-list-recent-saves")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        try server.start()
    }

    @MainActor
    override func tearDown() async throws {
        app.terminate()
        try server.stop()
        await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    @MainActor
    func test_navigatingToHomeTab_showsASectionForEachSlate() async {
        let home = app.launch().homeView

        home.sectionHeader("Slate 1").wait()
        home.element.swipeUp()

        home.recommendationCell("Slate 1, Recommendation 1").verify()
        home.recommendationCell("Slate 1, Recommendation 2").verify()

        home.element.swipeUp()

        home.sectionHeader("Slate 2").verify()
        home.recommendationCell("Slate 2, Recommendation 1").verify()

        async let slate1Rec1 = snowplowMicro.getFirstEvent(with: "home.slate.article.impression", recommendationId: "slate-1-rec-1")
        async let slate1Rec2 = snowplowMicro.getFirstEvent(with: "home.slate.article.impression", recommendationId: "slate-1-rec-2")
        async let slate2Rec1 = snowplowMicro.getFirstEvent(with: "home.slate.article.impression", recommendationId: "slate-2-rec-1")
        async let slate2Rec2 = snowplowMicro.getFirstEvent(with: "home.slate.article.impression", recommendationId: "slate-2-rec-2")

        let recs = await [slate1Rec1, slate1Rec2, slate2Rec1, slate2Rec2]
        let loadedSlate1Rec1 = recs[0]!
        let loadedSlate1Rec2 = recs[1]!
        let loadedSlate2Rec1 = recs[2]!
        let loadedSlate2Rec2 = recs[3]!

        snowplowMicro.assertRecommendationImpressionHasNecessaryContexts(event: loadedSlate1Rec1, url: "http://localhost:8080/slate-1-rec-1")
        snowplowMicro.assertRecommendationImpressionHasNecessaryContexts(event: loadedSlate1Rec2, url: "https://example.com/slate-1-rec-2")
        snowplowMicro.assertRecommendationImpressionHasNecessaryContexts(event: loadedSlate2Rec1, url: "https://example.com/recommended-item-3")
        snowplowMicro.assertRecommendationImpressionHasNecessaryContexts(event: loadedSlate2Rec2, url: "https://getpocket.com/explore/item/article-4")
    }

    @MainActor
    func test_navigatingToHomeTab_showsRecentlySavedItems() async {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.savedItemCell("Item 2").wait()
        home.savedItemCell("Item 1").swipeLeft(velocity: .fast)
        home.savedItemCell("Item 3").swipeLeft(velocity: .fast)
        waitForDisappearance(of: home.savedItemCell("Item 3"))
    }

    @MainActor
    func test_tappingRecentSavesItem_showsReader() async {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait().tap()
        app.readerView.wait()
        app.readerView.cell(containing: "Commodo Consectetur Dapibus").wait()
    }

    func test_tappingRecentSavesItem_showsWebViewWhenItemIsImage() {
        server.routes.get("/item-1") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }
        test_tappingRecentSavesItem_showsWebView("Item 1")
    }

    func test_tappingRecentSavesItem_showsWebViewWhenItemIsVideo() {
        server.routes.get("/item-2") { _, _ in
             Response {
                 Status.ok
                 Fixture.data(name: "hello", ext: "html")
             }
         }
        test_tappingRecentSavesItem_showsWebView("Item 2")
    }

    func test_tappingRecentSavesItem_showsWebViewWhenItemIsNotAnArticle() {
        server.routes.get("/item-3") { _, _ in
             Response {
                 Status.ok
                 Fixture.data(name: "hello", ext: "html")
             }
         }
        test_tappingRecentSavesItem_showsWebView("Item 3")
    }

    func test_favoritingRecentSavesItem_shouldShowFavoriteInSaves() {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").favoriteButton.tap()
        XCTAssertTrue(home.recentSavesView(matching: "Item 1").favoriteButton.isFilled)

        app.tabBar.savesButton.tap()
        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertTrue(app.saves.itemView(matching: "Item 1").favoriteButton.isFilled)
    }

    func test_unfavoritingRecentSavesItem_shouldNotAppearForFavoriteInSaves() {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 2").wait()
        XCTAssertTrue(home.recentSavesView(matching: "Item 2").favoriteButton.isFilled)
        home.recentSavesView(matching: "Item 2").favoriteButton.tap()
        XCTAssertFalse(home.recentSavesView(matching: "Item 2").favoriteButton.isFilled)

        app.tabBar.savesButton.tap()
        app.saves.filterButton(for: "Favorites").tap()
        waitForDisappearance(of: app.saves.itemView(matching: "Item 2"))
    }

    func test_archivingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.archiveButton.wait().tap()

        waitForDisappearance(of: home.savedItemCell("Item 1"))
    }

    func test_deletingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        waitForDisappearance(of: home.savedItemCell("Item 1"))

        app.tabBar.savesButton.tap()
        waitForDisappearance(of: app.saves.itemView(matching: "Item 1"))
    }

    func test_sharingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.launch().homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.shareButton.wait().tap()
        app.shareSheet.wait()
    }

    func test_tappingRecentSavesSavesButton_opensSavesView() {
        app.launch().homeView.sectionHeader("Recent Saves").seeAllButton.wait().tap()
        app.saves.itemView(matching: "Item 1").wait()
        XCTAssertTrue(app.saves.selectionSwitcher.savesButton.isSelected)
    }

    func test_tappingSlatesSeeAllButton_showsSlateDetailView() {
        let home = app.launch().homeView

        home.sectionHeader("Slate 1").seeAllButton.wait().tap()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").wait()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 2").wait()

        app.navigationBar.buttons["Home"].wait().tap()
        home.element.swipeUp()

        home.sectionHeader("Slate 2").seeAllButton.wait().tap()
        app.slateDetailView.recommendationCell("Slate 2, Recommendation 1").wait()
    }

    func test_slateDetails_savingARecommendation_addsItemToList() {
        let home = app.launch().homeView
        home.sectionHeader("Slate 1").seeAllButton.wait().tap()

        let cell = app.slateDetailView
            .recommendationCell("Slate 1, Recommendation 1")

        cell.saveButton.wait().tap()
        cell.savedButton.wait()

        app.navigationBar.buttons["Home"].tap()
        app.tabBar.savesButton.tap()
        app.saves.itemView(matching: "Slate 1, Recommendation 1").wait()
    }

    func test_tappingRecommendationCell_whenItemIsNotSaved_andItemIsNotSyndicated_opensItemInWebView() {
        server.routes.get("/slate-1-rec-1") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        app.launch().homeView.recommendationCell("Slate 1, Recommendation 1").wait().tap()
        app.webReaderView
            .staticText(matching: "Hello, world")
            .wait()
    }

    func test_tappingRecommendationCell_whenItemIsNotSaved_andItemIsSyndicated_opensItemInReaderView() {
        app.launch()
            .homeView.recommendationCell("Slate 1, Recommendation 1")
            .wait().element.swipeUp()

        app.homeView.recommendationCell("Syndicated Article Slate 2, Rec 2")
            .wait().tap()

        app.readerView.cell(containing: "Mozilla").wait()
    }

    func test_tappingRecommendationCell_whenItemIsNotSaved_andItemIsSyndicated_andUserGoesBack_SyndicationInfoStays() {
        app.launch()
            .homeView.recommendationCell("Slate 1, Recommendation 1")
            .wait().element.swipeUp()

        app.homeView.recommendationCell("Syndicated Article Slate 2, Rec 2")
            .wait().tap()

        app.readerView.cell(containing: "Syndicated Article Slate 2, Rec 2").wait()

        app.navigationBar.buttons["Home"].tap()

        XCTAssertTrue(app.homeView.recommendationCell("Syndicated Article Slate 2, Rec 2").element.staticTexts["Mozilla"].exists)
    }

    func test_tappingSaveButtonInRecommendationCell_savesItemToList() {
        let saveRequestExpectation = expectation(description: "A save mutation request")
        let archiveRequestExpectation = expectation(description: "An archive mutation request")

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                defer { saveRequestExpectation.fulfill() }
                XCTAssertEqual(apiRequest.inputURL, URL(string: "http://localhost:8080/slate-1-rec-1"))
                return .saveItem("save-recommendation-1")
            } else if apiRequest.isToArchiveAnItem {
                defer { archiveRequestExpectation.fulfill() }
                return .archive(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        let cell = app.launch().homeView.recommendationCell("Slate 1, Recommendation 1")
        cell.saveButton.tap()
        cell.savedButton.wait()

        app.tabBar.savesButton.tap()
        app.saves.itemView(matching: "Slate 1, Recommendation 1").wait()

        wait(for: [saveRequestExpectation])

        app.saves.itemView(matching: "Slate 1, Recommendation 1").wait()

        app.tabBar.homeButton.tap()

        cell.savedButton.tap()
        cell.saveButton.wait()

        wait(for: [archiveRequestExpectation])
        XCTAssertFalse(app.saves.itemView(matching: "Slate 1, Recommendation 1").exists)
    }

    func test_slateDetailsView_tappingSaveButtonInRecommendationCell_savesItemToList() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                if apiRequest.inputURL == URL(string: "http://localhost:8080/slate-1-rec-1") {
                    return Response.saveItem("save-recommendation-1")
                } else if apiRequest.inputURL == URL(string: "https://example.com/slate-1-rec-2") {
                    return Response.saveItem("save-recommendation-2")
                }
            } else if apiRequest.isToArchiveAnItem {
                if apiRequest.contains("slate-1-rec-1") {
                    XCTFail("Received archive request for unexpected item")
                } else {
                    return Response.archive(apiRequest: apiRequest)
                }
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()
            .homeView
            .sectionHeader("Slate 1")
            .seeAllButton
            .wait().tap()

        let rec1Cell = app.slateDetailView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        let coord = rec1Cell.element
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))

        let rec2Cell = app.slateDetailView
            .recommendationCell("Slate 1, Recommendation 2")
            .wait()

        rec1Cell.saveButton.wait().tap()
        rec1Cell.savedButton.wait()

        coord
            .press(
                forDuration: 0.1,
                thenDragTo: coord.withOffset(
                    .init(dx: 0, dy: -50)
                ),
                withVelocity: .default,
                thenHoldForDuration: 0.1
            )
        rec2Cell.saveButton.wait().tap()
        rec2Cell.savedButton.wait().tap()
        rec2Cell.saveButton.wait().tap()
        rec2Cell.savedButton.wait()
        rec1Cell.savedButton.wait()
    }

    func test_returningFromSaves_maintainsHomePosition() {
        let home = app.launch().homeView
        home.overscroll()
        validateBottomMessage()
        app.tabBar.savesButton.tap()
        app.tabBar.homeButton.tap()
        validateBottomMessage()
    }

    func test_returningFromSettings_maintainsHomePosition() {
        let home = app.launch().homeView
        home.overscroll()
        validateBottomMessage()
        app.tabBar.settingsButton.tap()
        app.tabBar.homeButton.tap()
        validateBottomMessage()
    }

    func test_returningFromReader_maintainsHomePosition() {
        let home = app.launch().homeView
        home.overscroll()
        validateBottomMessage()
        home.recommendationCell("Syndicated Article Slate 2, Rec 2").tap()
        app.readerView.readerHomeButton.wait().tap()
        validateBottomMessage()
    }

    func test_returningFromSeeAll_maintainsHomePosition() {
        let home = app.launch().homeView
        home.overscroll()
        validateBottomMessage()
        home.seeAllCollectionButton.tap()
        app.readerView.readerHomeButton.wait().tap()
        validateBottomMessage()
    }

    func validateBottomMessage() {
        XCTAssertTrue(app.homeView.overscrollText.exists)
    }
}

extension HomeTests {
    func test_pullToRefresh_fetchesUpdatedContent() {
        var slateLineupCalls = 0
        let slateUpdateExpectation = expectation(description: "expected to update slate lineup")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSlateLineup {
                defer { slateLineupCalls += 1 }
                switch slateLineupCalls {
                case 0:
                    return .slateLineup()
                default:
                    defer { slateUpdateExpectation.fulfill() }
                    return .slateLineup("updated-slates")
                }
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        let home = app.launch().homeView
        home.recommendationCell("Slate 1, Recommendation 1").wait()

        home.pullToRefresh()

        wait(for: [slateUpdateExpectation])
        home.recommendationCell("Updated Slate 1, Recommendation 1").wait()
    }

    // Disabled
    // Started failing in Xcode 13.2.1
    // Error: Failed to determine hittability of "home-overscroll" Other: Activation point invalid and no suggested hit points based on element frame
    func xtest_overscrollingHome_showsOverscrollView() {
        let home = app.homeView
        let overscrollView = home.overscrollView

        home.sectionHeader("Slate 1").wait()

        DispatchQueue.main.async {
            home.overscroll()
        }

        let exists = NSPredicate(format: "exists == 1")
        let doesExist = expectation(for: exists, evaluatedWith: overscrollView)
        let isHittable = NSPredicate(format: "isHittable == 1")
        let hittable = expectation(for: isHittable, evaluatedWith: overscrollView)
        wait(for: [doesExist, hittable], timeout: 100)
    }
}

extension HomeTests {
    private func test_tappingRecentSavesItem_showsWebView(_ item: String) {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves("list-for-web-view")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().homeView.wait()

        // If an item isn't initially visible (e.g "Item 3"),
        // take the first cell and swipe left so that it becomes visible.
        // This works because the fixture for "Saves" contains 3 items.
        // The first two tests for "Item 1" and "Item 2" work because
        // they are on-screen, but we have to scroll for "Item 3".
        if !app.homeView.savedItemCell(item).exists {
            app.homeView.savedItemCell(at: 0).swipeLeft()
        }

        app.homeView.savedItemCell(item).wait().tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait(timeout: 10)
    }
}
