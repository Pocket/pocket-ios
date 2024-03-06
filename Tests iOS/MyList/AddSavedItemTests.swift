// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

final class AddSavedItemTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    // MARK: - Lifecycle Methods

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        await snowplowMicro.resetSnowplowEvents()
        server = Application()
        stubGraphQLEndpoint(isPremium: false)
        try server.start()
        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
    }

    @MainActor
    override func tearDown() async throws {
        try server.stop()
        app.terminate()
        await snowplowMicro.assertBaselineSnowplowExpectation()
        try await super.tearDown()
    }

    func stubGraphQLEndpoint(isPremium: Bool) {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSearch(.saves) {
                return .searchList(.saves)
            } else if apiRequest.isForSearch(.archive) {
                return .searchList(.archive)
            } else if apiRequest.isForSearch(.all) {
                return .searchList(.all)
            } else if apiRequest.isForUserDetails {
                if isPremium {
                    return .premiumUserDetails()
                } else {
                    return .userDetails()
                }
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }
    }

    func checkForEvent(_ eventName: String, inverted: Bool = false) async {
        let event = await snowplowMicro.getFirstEvent(with: eventName)

        if inverted {
            XCTAssertNil(event, "\(eventName) should not be fired")
        } else {
            XCTAssertNotNil(event, "\(eventName) not fired")
        }
    }

    @MainActor
    func launchAndNavigateToAddSavedItem() async -> AddSavedItemElement {
        app.launch().tabBar.savesButton.wait().tap()
        let saves = app.saves.wait()

        saves.addSavedItemButton().tap()

        await checkForEvent("saves.addItem.open")

        return saves.addSavedItem
    }

    // MARK: - Tests
    @MainActor
    func test_showAndDismissAddItemView_analytics_cancelButton() async {
        let addSavedItem = await launchAndNavigateToAddSavedItem()

        addSavedItem.cancelButton.tap()

        await checkForEvent("saves.addItem.dismiss")
        await checkForEvent("saves.addItem.fail", inverted: true)
        await checkForEvent("saves.addItem.success", inverted: true)
    }

    @MainActor
    func test_showAndDismissAddItemView_analytics_closeButton() async {
        let addSavedItem = await launchAndNavigateToAddSavedItem()

        addSavedItem.closeButton.tap()

        await checkForEvent("saves.addItem.dismiss")
        await checkForEvent("saves.addItem.fail", inverted: true)
        await checkForEvent("saves.addItem.success", inverted: true)
    }

    @MainActor
    func test_addInvalidItem() async {
        let addSavedItem = await launchAndNavigateToAddSavedItem()

        let urlTextfield = addSavedItem.urlEntryTextField
        urlTextfield.tap()
        urlTextfield.typeText("not a valid URL")

        addSavedItem.addItemButton.wait().tap()

        await checkForEvent("saves.addItem.fail")
        await checkForEvent("saves.addItem.dismiss", inverted: true)
        await checkForEvent("saves.addItem.success", inverted: true)

        XCTAssertTrue(addSavedItem.errorMessage.exists, "Expected error message not shown")
    }

    @MainActor
    func test_addValidItem() async {
        let addSavedItem = await launchAndNavigateToAddSavedItem()

        let urlTextfield = addSavedItem.urlEntryTextField
        urlTextfield.tap()
        urlTextfield.typeText("https://www.mozilla.org/")

        addSavedItem.addItemButton.wait().tap()

        await checkForEvent("saves.addItem.success")
        await checkForEvent("saves.addItem.dismiss", inverted: true)
        await checkForEvent("saves.addItem.fail", inverted: true)

        XCTAssertFalse(addSavedItem.errorMessage.exists, "Error message should not be shown")
    }
}
