// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class SaveToPocketTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.continueAfterFailure = false

        server = Application()
        app = PocketAppElement(app: XCUIApplication())

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
        let reminders = XCUIApplication(bundleIdentifier: "com.apple.reminders")
        reminders.terminate()
        try super.tearDownWithError()
    }

    func test_whenLoggedOut_userTapsLogIn_opensApp() {
        app.launch(arguments: .bypassSignIn, environment: .noSession)

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/hello\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()
        let activityView = safari.descendants(matching: .other)["ActivityListView"].wait()

        activityView.cells["Pocket"].tap()
        safari.buttons["log-in"].wait().tap()

        app.loggedOutView.wait()
    }

    func test_userAddTags_showsConfirmationView() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                return .savedItemWithTag()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/hello\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()
        tapPocketShareMenuIcon()
        safari.buttons["add-tags-button"].wait().tap()

        let addTagsView = AddTagsViewElement(safari.otherElements["add-tags"])

        addTagsView.wait()
        addTagsView.clearTagsTextfield()

        addTagsView.saveButton.wait().tap()
        safari.staticTexts["Hello, world"].wait()
    }

    func test_userSharesTextWithValidURL_showsConfirmationView() {
        app.launch(arguments: .bypassSignIn, environment: .withSession)
        let reminders = XCUIApplication(bundleIdentifier: "com.apple.reminders")
        reminders.launch()
        if !reminders.buttons["New Reminder"].isHittable {
            reminders.buttons["Continue"].wait().tap()
        }
        reminders.buttons["New Reminder"].wait().tap()
        reminders.typeText("Get Pocket https://getpocket.com")
        reminders.textFields.firstMatch.wait().tap()
        reminders.textFields.firstMatch.wait().tap()
        reminders.menuItems["Select All"].wait().tap()
        reminders.buttons["Forward"].wait().tap()
        reminders.collectionViews.staticTexts["Share…"].tap()
        let activityView = reminders.descendants(matching: .other)["ActivityListView"].wait()
        activityView.cells["Pocket"].tap()
        reminders.otherElements["save-extension-info-view"].staticTexts["Saved to Pocket"].wait()
        reminders.terminate()
    }

    func test_userSharesTextWithNoURL_showsErrorView() {
        app.launch(arguments: .bypassSignIn, environment: .withSession)
        let reminders = XCUIApplication(bundleIdentifier: "com.apple.reminders")
        reminders.launch()
        if !reminders.buttons["New Reminder"].isHittable {
            reminders.buttons["Continue"].wait().tap()
        }
        reminders.buttons["New Reminder"].wait().tap()
        reminders.typeText("Get Pocket")
        reminders.textFields.firstMatch.wait().tap()
        reminders.textFields.firstMatch.wait().tap()
        reminders.menuItems["Select All"].wait().tap()
        reminders.buttons["Forward"].wait().tap()
        reminders.collectionViews.staticTexts["Share…"].tap()
        let activityView = reminders.descendants(matching: .other)["ActivityListView"].wait()
        activityView.cells["Pocket"].tap()
        reminders.otherElements["save-extension-info-view"].staticTexts["Pocket couldn't save this link"].wait()
        reminders.terminate()
    }

    func tapPocketShareMenuIcon() {
        let safariShareMenu = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let activityView = safariShareMenu.descendants(matching: .other)["ActivityListView"].wait()
        activityView.cells["Pocket"].tap()
    }
}
