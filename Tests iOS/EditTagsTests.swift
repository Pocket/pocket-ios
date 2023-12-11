// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class EditTagsTests: XCTestCase {
    var app: PocketAppElement!
    var server: Application!
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

    @MainActor
    func test_editTagsView_renamesTag() async {
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
        tagsFilterView.tag(matching: "rename tag 1").wait().tap()
        XCTAssertEqual(app.saves.wait().itemCells.count, 1)

        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.filterTags.tagRename")
        tagEvent!.getUIContext()!.assertHas(type: "button")
    }

    @MainActor
    func test_editTagsView_deletesTag() async {
        let deleteRequest = expectation(description: "delete request")
        deleteRequest.expectedFulfillmentCount = 2
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToDeleteATag {
                deleteRequest.fulfill()
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
        wait(for: [deleteRequest])
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 1"))
        waitForDisappearance(of: tagsFilterView.tag(matching: "tag 2"))

        let tagEvent = await snowplowMicro.getFirstEvent(with: "global-nav.filterTags.tagsDelete")
        tagEvent!.getUIContext()!.assertHas(type: "button")
    }
}
