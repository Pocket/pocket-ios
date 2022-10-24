// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class EditTagsTests: XCTestCase {
    var app: PocketAppElement!
    var server: Application!

    override func setUpWithError() throws {
        continueAfterFailure = false
        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isToUpdateTag("rename tag 1") {
                return Response.updateTag()
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

    func test_editTagsView_renamesTag() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.myListView.tagsFilterView.wait()

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
        XCTAssertEqual(app.myListView.wait().itemCells.count, 1)
    }

    func test_editTagsView_deletesTag() {
        app.tabBar.myListButton.wait().tap()
        app.myListView.filterButton(for: "Tagged").tap()
        let tagsFilterView = app.myListView.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.editButton.label, "Edit")
        tagsFilterView.editButton.wait().tap()
        XCTAssertEqual(tagsFilterView.editButton.label, "Done")
        XCTAssertFalse(tagsFilterView.deleteButton.isEnabled)

        tagsFilterView.tag(matching: "tag 1").tap()
        tagsFilterView.tag(matching: "tag 2").tap()

        XCTAssertTrue(tagsFilterView.deleteButton.isEnabled)
        tagsFilterView.deleteButton.tap()

        let firstDeleteRequest = expectation(description: "first delete request")
        let secondDeleteRequest = expectation(description: "second delete request")
        firstDeleteRequest.assertForOverFulfill = false
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteATag() {
                firstDeleteRequest.fulfill()
                return Response.deleteTag()
            } else if apiRequest.isToDeleteATag(2) {
                secondDeleteRequest.fulfill()
                return Response.deleteTag("delete-tag-2")
            } else {
                fatalError("Unexpected request")
            }
        }

        app.alert.delete.wait().tap()
        wait(for: [firstDeleteRequest, secondDeleteRequest])
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 1"))
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 2"))
    }
}
