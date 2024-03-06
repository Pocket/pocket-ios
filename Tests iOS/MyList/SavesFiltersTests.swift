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

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
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
        try await super.tearDown()
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

    @MainActor
    func test_savesView_tappingTaggedPill_withFreeUser_showsFilteredItems() async {
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

        app.saves.filterButton(for: "Tagged").wait().tap()
        tagsFilterView.wait().tag(matching: "filter tag 0").wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)

        let events = await [
            snowplowMicro.getFirstEvent(with: "global-nav.filterTags.selectNotTagged"),
            snowplowMicro.getFirstEvent(with: "global-nav.filterTags.selectTag")
        ]

        let tagEvent = events[0]!
        tagEvent.getUIContext()!.assertHas(type: "button")

        let tagEvent1 = events[1]!
        tagEvent1.getUIContext()!.assertHas(type: "button")
    }

    @MainActor
    func test_savesView_tappingTaggedPill_withPremiumUser_showsFilteredItems() async {
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
        tagsFilterView.recentTagCells.element(boundBy: 0).wait().tap()

        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.filterTags.selectRecentTag")
        tagEvent!.getUIContext()!.assertHas(type: "button")
    }

    func test_savesView_tappingSortPill_withSelectedTag_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()
        tagsFilterView.tag(matching: "tag 0").wait().tap()

        app.saves.filterButton(for: "Sort").wait().tap()
        app.sortMenu.sortOption("Oldest saved").wait().tap()

        XCTAssertTrue(app.saves.itemView(at: 0).contains(string: "Item 2"))
        XCTAssertTrue(app.saves.itemView(at: 1).contains(string: "Item 1"))
    }
}
