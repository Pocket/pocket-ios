// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class ArchiveFiltersTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

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

    func test_archiveView_tappingFavoritesPill_togglesDisplayingFavoritedArchivedContent() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()
        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()

        app.saves.filterButton(for: "Favorites").wait().tap()
        waitForDisappearance(of: saves.itemView(matching: "Archived Item 1"))
        saves.itemView(matching: "Archived Item 2").wait()
        app.saves.filterButton(for: "Favorites").wait().tap()

        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingAllPill_togglesDisplayingAllArchivedContent() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "All").wait().tap()
        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()

        app.saves.filterButton(for: "Favorites").wait().tap()
        waitForDisappearance(of: saves.itemView(matching: "Archived Item 1"))

        app.saves.filterButton(for: "All").wait().tap()
        saves.itemView(matching: "Archived Item 1").wait()
        saves.itemView(matching: "Archived Item 2").wait()
    }

    func test_archiveView_tappingTaggedFilter_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        tagsFilterView.tag(matching: "tag 0").wait().tap()
        waitForDisappearance(of: tagsFilterView)

        app.saves.selectedTagChip(for: "tag 0").wait()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    @MainActor
    func test_archiveView_usingTagFilter_withFreeUser_showFilteredItems() async {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        tagsFilterView.tag(matching: "not tagged").wait().tap()
        waitForDisappearance(of: tagsFilterView)

        XCTAssertEqual(app.saves.wait().itemCells.count, 1)

        app.saves.filterButton(for: "Tagged").wait().tap()
        tagsFilterView.wait().tag(matching: "filter tag 0").wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 0)

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
    func test_archiveView_usingRecentTagFilter_withPremiumUser_showFilteredItems() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()

        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()
        tagsFilterView.recentTagCells.element(boundBy: 0).wait().tap()

        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.filterTags.selectRecentTag")
        tagEvent!.getUIContext()!.assertHas(type: "button")
    }

    func test_archiveView_tappingSortPill_withSelectedTag_showsFilteredItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()
        tagsFilterView.tag(matching: "tag 0").wait().tap()

        app.saves.filterButton(for: "Sort").wait().tap()
        app.sortMenu.sortOption("Oldest saved").wait().tap()

        XCTAssertTrue(app.saves.itemView(at: 0).contains(string: "Archived Item 1"))
    }
}
