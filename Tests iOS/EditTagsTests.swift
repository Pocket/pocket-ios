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

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToUpdateTag("rename tag 1") {
                return .updateTag()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_editTagsView_renamesTag() {
        app.launch()
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
        scrollTo(element: tagsFilterView.tag(matching: "rename tag 1"), in: tagsFilterView.element, direction: .up)
        tagsFilterView.tag(matching: "rename tag 1").wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)
    }

    func test_editTagsView_deletesTag() {
        let firstDeleteRequest = expectation(description: "first delete request")
        let secondDeleteRequest = expectation(description: "second delete request")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteATag() {
                firstDeleteRequest.fulfill()
                return Response.deleteTag()
            } else if apiRequest.isToDeleteATag(2) {
                secondDeleteRequest.fulfill()
                return Response.deleteTag("delete-tag-2")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch()
        app.tabBar.savesButton.wait().tap()
        app.saves.filterButton(for: "Tagged").wait().tap()
        let tagsFilterView = app.saves.tagsFilterView.wait()

        XCTAssertEqual(tagsFilterView.editButton.label, "Edit")
        tagsFilterView.editButton.wait().tap()
        XCTAssertEqual(tagsFilterView.editButton.label, "Done")
        XCTAssertFalse(tagsFilterView.deleteButton.isEnabled)

        tagsFilterView.tag(matching: "tag 1").wait().tap()
        tagsFilterView.tag(matching: "tag 2").wait().tap()

        XCTAssertTrue(tagsFilterView.deleteButton.isEnabled)
        tagsFilterView.deleteButton.wait().tap()

        app.alert.delete.wait().tap()
        wait(for: [firstDeleteRequest, secondDeleteRequest])
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 1"))
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 2"))
    }
}
