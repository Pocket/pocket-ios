// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO


class HomeTests: XCTestCase {
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
            } else if apiRequest.isForSlateDetail() {
                return Response.slateDetail()
            } else if apiRequest.isForSlateDetail(2) {
                return Response.slateDetail(2)
            } else if apiRequest.isForMyListContent {
                return Response.myList("initial-list-recent-saves")
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isToArchiveAnItem {
                return Response.archive()
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
            } else if apiRequest.isToDeleteAnItem {
                return Response.delete()
            } else {
                fatalError("Unexpected request")
            }
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_navigatingToHomeTab_showsASectionForEachSlate() {
        let home = app.homeView

        home.sectionHeader("Slate 1").wait()
        home.element.swipeUp()
        
        home.recommendationCell("Slate 1, Recommendation 1").verify()
        home.recommendationCell("Slate 1, Recommendation 2").verify()

        home.element.swipeUp()

        home.sectionHeader("Slate 2").verify()
        home.recommendationCell("Slate 2, Recommendation 1").verify()
    }
    
    func test_navigatingToHomeTab_showsRecentlySavedItems() {
        let home = app.homeView.wait()
        
        home.savedItemCell("Item 1").wait()
        home.savedItemCell("Item 2").wait()
        
        home.savedItemCell("Item 1").swipeLeft(velocity: .fast)
        home.savedItemCell("Item 3").swipeLeft(velocity: .fast)
        waitForDisappearance(of: home.savedItemCell("Item 6"))
    }
    
    func test_favoritingRecentSavesItem_shouldShowFavoriteInMyList() {
        let home = app.homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").favoriteButton.tap()
        XCTAssertTrue(home.recentSavesView(matching: "Item 1").favoriteButton.isFilled)

        app.tabBar.myListButton.tap()
        app.myListView.filterButton(for: "Favorites").tap()
        XCTAssertTrue(app.myListView.itemView(matching: "Item 1").favoriteButton.isFilled)
    }
    
    func test_unfavoritingRecentSavesItem_shouldNotAppearForFavoriteInMyList() {
        let home = app.homeView.wait()
        home.savedItemCell("Item 2").wait()
        XCTAssertTrue(home.recentSavesView(matching: "Item 2").favoriteButton.isFilled)
        home.recentSavesView(matching: "Item 2").favoriteButton.tap()
        XCTAssertFalse(home.recentSavesView(matching: "Item 2").favoriteButton.isFilled)
        
        app.tabBar.myListButton.tap()
        app.myListView.filterButton(for: "Favorites").tap()
        waitForDisappearance(of: app.myListView.itemView(matching: "Item 2"))
    }

    func test_archivingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.archiveButton.wait().tap()

        waitForDisappearance(of: home.savedItemCell("Item 1"))
    }
    
    func test_deletingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.deleteButton.wait().tap()
        app.alert.yes.wait().tap()
        waitForDisappearance(of: home.savedItemCell("Item 1"))
        
        app.tabBar.myListButton.tap()
        waitForDisappearance(of: app.myListView.itemView(matching: "Item 1"))
    }
    
    func test_sharingRecentSavesItem_removesItemFromRecentSaves() {
        let home = app.homeView.wait()
        home.savedItemCell("Item 1").wait()
        home.recentSavesView(matching: "Item 1").overflowButton.wait().tap()
        app.shareButton.wait().tap()
        app.shareSheet.wait()
    }

    func test_tappingRecentSavesMyListButton_opensMyListView() {
        app.homeView.sectionHeader("Recent Saves").seeAllButton.wait().tap()
        app.myListView.itemView(matching: "Item 1").wait()
        XCTAssertTrue(app.myListView.selectionSwitcher.myListButton.isSelected)
    }
    
    func test_tappingRecentSavesMyListButton_whenPreviouslyArchiveView_opensMyListView() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.selectionSwitcher.archiveButton.wait().tap()
        app.tabBar.homeButton.wait().tap()
        app.homeView.sectionHeader("Recent Saves").seeAllButton.wait().tap()
        app.myListView.itemView(matching: "Item 1").wait()
        XCTAssertTrue(app.myListView.selectionSwitcher.myListButton.isSelected)
    }
    
    func test_tappingSlatesSeeAllButton_showsSlateDetailView() {
        let home = app.homeView
        
        home.sectionHeader("Slate 1").seeAllButton.wait().tap()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 1").wait()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 2").verify()
        app.slateDetailView.element.swipeUp()
        app.slateDetailView.recommendationCell("Slate 1, Recommendation 3").verify()

        app.tabBar.homeButton.wait().tap()
        home.element.swipeUp()

        home.sectionHeader("Slate 2").seeAllButton.wait().tap()
        app.slateDetailView.recommendationCell("Slate 2, Recommendation 1").wait()
    }
    
    func test_tappingRecommendationCell_opensItemInReader() {
        app.homeView.recommendationCell("Slate 1, Recommendation 1").wait().tap()
        app.readerView.cell(containing: "Jacob and David").wait()
    }
    
    func test_tappingSaveButtonInRecommendationCell_savesItemToList() {
        let cell = app.homeView.recommendationCell("Slate 1, Recommendation 1")
        let saveButton = cell.saveButton.wait()

        let saveRequestExpectation = expectation(description: "A save mutation request")
        let archiveRequestExpectation = expectation(description: "An archive mutation request")
        var promise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSlateDetail() {
                return Response.slateDetail()
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToSaveAnItem {
                XCTAssertTrue(apiRequest.contains("https:\\/\\/example.com\\/item-1"))
                saveRequestExpectation.fulfill()
                promise = loop.makePromise()
                return promise!.futureResult
            } else if apiRequest.isToArchiveAnItem {
                archiveRequestExpectation.fulfill()
                return Response.archive()
            } else {
                fatalError("Unexpected request")
            }
        }

        saveButton.tap()
        XCTAssertEqual(saveButton.label, "Saved")

        app.tabBar.myListButton.tap()
        app.myListView.itemView(matching: "Slate 1, Recommendation 1").wait()

        wait(for: [saveRequestExpectation], timeout: 1)

        promise?.succeed(Response.saveItem())
        app.myListView.itemView(matching: "Slate 1, Recommendation 1").wait()

        app.tabBar.homeButton.tap()
        saveButton.tap()

        XCTAssertEqual(saveButton.label, "Save")
        wait(for: [archiveRequestExpectation], timeout: 1)
        XCTAssertFalse(app.myListView.itemView(matching: "Slate 1, Recommendation 1").exists)
    }
}

extension HomeTests {
    func test_pullToRefresh_fetchesUpdatedContent() {
        let home = app.homeView
        home.recommendationCell("Slate 1, Recommendation 1").wait()
        
        server.routes.post("/graphql") { request, _ in
            Response.slateLineup("updated-slates")
        }
        
        home.pullToRefresh()
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
        wait(for: [doesExist, hittable], timeout: 20)
    }
}
