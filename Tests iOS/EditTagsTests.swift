// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class EditTagsTests: XCTestCase {
    var app: PocketAppElement!
    var server: Application!

    var firstDeleteRequest: XCTestExpectation?
    var secondDeleteRequest: XCTestExpectation?

    override func setUpWithError() throws {
        continueAfterFailure = false
        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") {[unowned self] request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToUpdateTag("rename tag 1") {
                return Response.updateTag()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isToDeleteATag() {
                defer { firstDeleteRequest?.fulfill() }
                return Response.deleteTag()
            } else if apiRequest.isToDeleteATag(2) {
                defer { secondDeleteRequest?.fulfill() }
                return Response.deleteTag("delete-tag-2")
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }

        try server.start()
        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_editTagsView_renamesTag() {
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.editButton.label, "Edit")
        tagsFilterView.editButton.wait().tap()
        XCTAssertEqual(tagsFilterView.editButton.label, "Done")
        XCTAssertFalse(tagsFilterView.renameButton.isEnabled)

        tagsFilterView.tag(matching: "tag 1").tap()
        tagsFilterView.tag(matching: "tag 0").tap()
        XCTAssertFalse(tagsFilterView.renameButton.isEnabled)

        tagsFilterView.tag(matching: "tag 0").tap()
        XCTAssertTrue(tagsFilterView.renameButton.isEnabled)

        tagsFilterView.renameButton.tap()
        app.alert.element.textFields.firstMatch.typeText("rename tag 1")
        app.alert.ok.wait().tap()

        tagsFilterView.tag(matching: "rename tag 1").wait()
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 1"))

        tagsFilterView.editButton.wait().tap()
        tagsFilterView.tag(matching: "rename tag 1").wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_editTagsView_deletesTag() {
        firstDeleteRequest = expectation(description: "first delete request")
        firstDeleteRequest!.assertForOverFulfill = true
        secondDeleteRequest = expectation(description: "second delete request")
        secondDeleteRequest!.assertForOverFulfill = true

        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.editButton.label, "Edit")
        tagsFilterView.editButton.wait().tap()
        XCTAssertEqual(tagsFilterView.editButton.label, "Done")
        XCTAssertFalse(tagsFilterView.deleteButton.isEnabled)

        tagsFilterView.tag(matching: "tag 1").tap()
        tagsFilterView.tag(matching: "tag 2").tap()

        XCTAssertTrue(tagsFilterView.deleteButton.isEnabled)
        tagsFilterView.deleteButton.tap()

        app.alert.delete.wait().tap()
        wait(for: [firstDeleteRequest!, secondDeleteRequest!])
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 1"))
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 2"))
    }
}
