import XCTest
import Sails

class SaveToPocketTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        self.continueAfterFailure = false

        server = Application()
        app = PocketAppElement(app: XCUIApplication())

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_whenLoggedOut_userTapsLogIn_opensApp() {
        app.launch(arguments: .firstLaunch, environment: .noSession)

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/hello\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()
        let activityView = safari.descendants(matching: .other)["ActivityListView"].wait()

        // Sadly this is the only way I could devise to find the Pocket Beta button
        // This will likely be very brittle
        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
        safari.buttons["log-in"].wait().tap()

        app.loggedOutView.wait()
    }

    func test_userAddTags_showsConfirmationView() {
        app.launch()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/hello\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()
        let activityView = safari.descendants(matching: .other)["ActivityListView"].wait()

        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
        safari.buttons["add-tags-button"].wait().tap()

        let addTagsView = AddTagsViewElement(safari.otherElements["add-tags"])
        var tagString = "tag 1"

        addTagsView.wait()
        addTagsView.newTagTextField.tap()
        addTagsView.newTagTextField.typeText(tagString)
        addTagsView.newTagTextField.typeText("\n")

        addTagsView.tag(matching: tagString).wait()

        // response to typeText not typing "tag 1" 100% of the time
        // short term work around
        if (!addTagsView.tag(matching: tagString).exists) {
            addTagsView.tag(matching: "ta 1").wait()
            if (!addTagsView.tag(matching: "ta 1").exists) {
                tagString = "ta 1"
            }
        }

        server.routes.post("/graphql") { request, _ in
            Response.savedItemWithTag()
        }

        addTagsView.saveButton.tap()
        safari.staticTexts["Tags Added!"].wait()
        safari.staticTexts["Tap to Dismiss"].tap()

        safari.toolbars.buttons["ShareButton"].tap()
        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
        safari.buttons["add-tags-button"].wait().tap()
        addTagsView.tag(matching: tagString).wait()
    }
}
