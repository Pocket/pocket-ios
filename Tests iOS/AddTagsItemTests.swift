// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class AddTagsItemTests: XCTestCase {
    var server: Sails.Application!
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

    override func tearDown() async throws {
       await snowplowMicro.assertNoBadEvents()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    @MainActor
    func test_addTagsToItemFromSaves_withPremiumUser_savesNewTags() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        app.launch().tabBar.savesButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Item 1")
        itemCell.itemActionButton.wait().tap()
        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.clearTagsTextfield()
        let randomTagName = String(addTagsView.enterRandomTagName())
        addTagsView.saveButton.tap()
        selectTaggedFilterButton()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        tagsFilterView.recentTagCells.element.wait()
        XCTAssertEqual(tagsFilterView.recentTagCells.count, 3)

        scrollTo(element: tagsFilterView.allTagCells(matching: "tag 2"), in: tagsFilterView.element, direction: .up)
        XCTAssertEqual(tagsFilterView.allTagSectionCells.count, 7)

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.addTags.save")
        tagEvent!.getUIContext()!.assertHas(type: "button")
        tagEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_addTagsToItemFromSaves_savesFromExistingTags() async {
        app.launch().tabBar.savesButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Item 1")
        itemCell.itemActionButton.wait().tap()

        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.wait()

        addTagsView.tag(matching: "tag 0").wait().tap()

        scrollTo(element: addTagsView.allTagCells(matching: "tag 0"), in: addTagsView.allTagsView, direction: .up)
        addTagsView.allTagCells(matching: "tag 0").wait()

        scrollTo(element: addTagsView.allTagCells(matching: "tag 1"), in: addTagsView.allTagsView, direction: .down)
        addTagsView.allTagCells(matching: "tag 1").wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()

        let events = await [snowplowMicro.getFirstEvent(with: "global-nav.addTags.removeInputTag"), snowplowMicro.getFirstEvent(with: "global-nav.addTags.addTag")]

        let removeTagEvent = events[0]!
        removeTagEvent.getUIContext()!.assertHas(type: "button")
        removeTagEvent.getContentContext()!.assertHas(url: "http://localhost:8080/hello")

        let addTagEvent = events[1]!
        addTagEvent.getUIContext()!.assertHas(type: "button")
        addTagEvent.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_addTagsToItemFromArchive_withPremiumUser_showsAddTagsView() async {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForUserDetails {
                return Response.premiumUserDetails()
            }
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.wait().selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Archived Item 2")

        itemCell
            .itemActionButton.wait()
            .tap()

        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.wait()
        addTagsView.newTagTextField.tap()
        addTagsView.newTagTextField.typeText("Tag 1")
        addTagsView.newTagTextField.typeText("\n")

        scrollTo(element: addTagsView.allTagCells(matching: "tag 1"), in: addTagsView.element, direction: .up)
        addTagsView.tag(matching: "tag 1").wait()

        addTagsView.saveButton.tap()

        itemCell.itemActionButton.wait().tap()
        app.addTagsButton.wait().tap()
        app.addTagsView.wait()

        addTagsView.recentTagCells.element.wait()
        XCTAssertEqual(app.addTagsView.recentTagCells.count, 3)

        scrollTo(element: addTagsView.allTagCells(matching: "tag 2"), in: addTagsView.allTagsView, direction: .up)
        XCTAssertEqual(app.addTagsView.allTagSectionCells.count, 7)

        await snowplowMicro.assertBaselineSnowplowExpectation()

        let events = await [snowplowMicro.getFirstEvent(with: "global-nav.addTags.allTags"), snowplowMicro.getFirstEvent(with: "global-nav.addTags.userEntersText")]

        let tagEvent = events[0]!
        tagEvent.getUIContext()!.assertHas(type: "screen")
        tagEvent.getContentContext()!.assertHas(url: "https://example.com/items/archived-item-2")

        let tagEvent2 = events[1]!
        tagEvent2.getUIContext()!.assertHas(type: "dialog")
        tagEvent2.getContentContext()!.assertHas(url: "https://example.com/items/archived-item-2")
    }

    @MainActor
    func test_addTagsToSavedItemFromReader_showsAddTagsView() async {
        app.launch().tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(matching: "Item 1")
            .wait()
            .tap()

        app
            .readerView
            .readerToolbar
            .moreButton.wait()
            .tap()

        app.addTagsButton.wait().tap()
        app.addTagsView.wait()
        app.addTagsView.allTagSectionCells.element.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.addTags.allTags")
        tagEvent!.getUIContext()!.assertHas(type: "screen")
        tagEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_textField_withUserInput_showsFilteredTags() async {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.wait().selectionSwitcher.archiveButton.wait().tap()

        let itemCell = app
            .saves
            .itemView(matching: "Archived Item 2")
            .wait()

        itemCell
            .itemActionButton.wait()
            .tap()

        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.wait()
        addTagsView.newTagTextField.tap()
        addTagsView.newTagTextField.typeText("F")
        addTagsView.newTagTextField.typeText("\n")

        scrollTo(element: addTagsView.allTagCells(matching: "filter tag 0"), in: addTagsView.allTagsView, direction: .up)
        addTagsView.allTagCells(matching: "filter tag 0").wait()

        scrollTo(element: addTagsView.allTagCells(matching: "filter tag 1"), in: addTagsView.allTagsView, direction: .up)
        addTagsView.allTagCells(matching: "filter tag 1").wait()
        app.addTagsView.allTagSectionCells.element.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.addTags.filteredTags")
        tagEvent!.getUIContext()!.assertHas(type: "screen")
        tagEvent!.getContentContext()!.assertHas(url: "https://example.com/items/archived-item-2")
    }

    func selectTaggedFilterButton() {
        app.saves.filterButton(for: "Tagged").wait().tap()
    }
}
