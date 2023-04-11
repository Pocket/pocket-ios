// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class SavesFiltersTests: XCTestCase {
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
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        try server.start()
    }

    @MainActor
    override func tearDown() async throws {
       try server.stop()
       app.terminate()
       await snowplowMicro.assertBaselineSnowplowExpectation()
    }

    func test_savesView_tappingFavoritesPill_showsOnlyFavoritedItems() {
        app.launch().tabBar.savesButton.wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 0)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
        app.saves.itemView(at: 0).favoriteButton.tap()

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_savesView_tappingAllPill_showsAllItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(at: 0).wait().favoriteButton.tap()

        app.saves.filterButton(for: "All").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        app.saves.filterButton(for: "Favorites").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)

        app.saves.filterButton(for: "All").tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }

    func test_savesView_tappingTaggedPill_withFreeUser_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()
        tagsFilterView.tag(matching: "not tagged").wait()

        scrollTo(element: tagsFilterView.allTagCells(matching: "tag 2"), in: tagsFilterView.element, direction: .up)
        XCTAssertEqual(tagsFilterView.allTagSectionCells.count, 6)

        tagsFilterView.tag(matching: "not tagged").wait().tap()

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "not tagged").wait()
        app.saves.selectedTagChip(for: "not tagged").buttons.element(boundBy: 0).tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }

    func test_savesView_tappingTaggedPill_withPremiumUser_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()
        tagsFilterView.tag(matching: "not tagged").wait()

        scrollTo(element: tagsFilterView.allTagCells(matching: "tag 2"), in: tagsFilterView.element, direction: .up)
        XCTAssertEqual(tagsFilterView.allTagSectionCells.count, 6)

        tagsFilterView.tag(matching: "not tagged").wait().tap()

        XCTAssertEqual(app.saves.wait().itemCells.count, 0)
        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "not tagged").wait()
        app.saves.selectedTagChip(for: "not tagged").buttons.element(boundBy: 0).tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)
    }

    @MainActor
    func test_savesView_tappingTaggedPill_withRecentTag_showsFilteredItem() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        tagsFilterView.recentTagCells.element.wait()
        XCTAssertEqual(tagsFilterView.recentTagCells.count, 3)

        tagsFilterView.recentTagCells.element(boundBy: 0).tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 2)

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.filterTags.recentTags")
        tagEvent!.getUIContext()!.assertHas(type: "button")
    }
}
