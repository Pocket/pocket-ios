// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class AddTagsItemTests: XCTestCase {
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
            } else if apiRequest.isForRecommendationDetail(1) {
                return Response.recommendationDetail(1)
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_addTagsToItemFromSaves_savesNewTags() {
        app.tabBar.savesButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Item 1")
        itemCell.itemActionButton.wait().tap()
        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.clearTagsTextfield()
        let randomTagName = String(addTagsView.enterRandomTagName())
        server.routes.post("/graphql") { request, _ in
            Response.savedItemWithTag()
        }
        addTagsView.saveButton.tap()
        selectTaggedFilterButton()
        app.saves.tagsFilterView.wait()
        XCTAssertEqual(app.saves.tagsFilterView.tagCells.count, 7)
    }

    func test_addTagsToItemFromSaves_savesFromExistingTags() {
        app.tabBar.savesButton.wait().tap()
        let itemCell = app.saves.itemView(matching: "Item 1")
        itemCell.itemActionButton.wait().tap()

        app.addTagsButton.wait().tap()
        let addTagsView = app.addTagsView.wait()
        addTagsView.wait()

        addTagsView.tag(matching: "tag 0").wait().tap()
        addTagsView.allTagsRow(matching: "tag 0").wait()

        addTagsView.allTagsRow(matching: "tag 1").wait().tap()
        waitForDisappearance(of: addTagsView.allTagsRow(matching: "tag 1"))
    }

    func test_addTagsToItemFromArchive_showsAddTagsView() {
        app.tabBar.savesButton.wait().tap()
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

        addTagsView.tag(matching: "tag 1").wait()

        server.routes.post("/graphql") { request, _ in
            Response.savedItemWithTag()
        }

        addTagsView.saveButton.tap()

        server.routes.post("/graphql") { request, _ in
            Response.archivedContent()
        }

        itemCell.itemActionButton.wait().tap()
        app.addTagsButton.wait().tap()
        app.addTagsView.wait()
    }

    func test_addTagsToSavedItemFromReader_showsAddTagsView() {
        app.tabBar.savesButton.wait().tap()

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
        app.addTagsView.allTagsView.wait()
    }

    func test_textField_withUserInput_showsFilteredTags() {
        app.tabBar.savesButton.wait().tap()
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
        addTagsView.newTagTextField.typeText("f")

        addTagsView.allTagsRow(matching: "filter tag 0").wait()
        addTagsView.allTagsRow(matching: "filter tag 1").wait()
    }

    func selectTaggedFilterButton() {
        app.saves.filterButton(for: "Tagged").tap()
    }
}
