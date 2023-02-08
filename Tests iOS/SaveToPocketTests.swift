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
        tapPocketShareMenuIcon()
        safari.buttons["add-tags-button"].wait().tap()

        let addTagsView = AddTagsViewElement(safari.otherElements["add-tags"])

        addTagsView.wait()
        addTagsView.clearTagsTextfield()
        let randomTagName = String(addTagsView.enterRandomTagName())
        server.routes.post("/graphql") { request, _ in
            Response.savedItemWithTag()
        }
        addTagsView.saveButton.tap()
        safari.staticTexts["Hello, world"].wait()
    }

    func tapPocketShareMenuIcon() {
        let safariShareMenu = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let activityView = safariShareMenu.descendants(matching: .other)["ActivityListView"].wait()
        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
    }
}
