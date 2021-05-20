// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class Tests_iOS: XCTestCase {
    var server: Application!
    var app: PocketApp!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketApp(app: uiApp)

        server = Application()

        server.routes.post("/") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "initial-list")
            }
        }

        server.routes.post("/v3/oauth/authorize") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content: Fixture.data(name: "successful-auth")
            )
        }

        server.routes.get("/hello.html") { _, _ in
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

    func test_1_signingIn_whenSigninIsSuccessful_showsUserList() {
        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData"
            ]
        )
        
        let signInView = app.signInView()
        XCTAssertTrue(signInView.waitForExistence())
        signInView.signIn(
            email: "test@example.com",
            password: "super-secret-password"
        )

        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        do {
            let item = listView.itemView(withLabelStartingWith: "Item 1")
            XCTAssertTrue(item.waitForExistence())
            XCTAssertTrue(item.contains(string: "Pocket"))
            XCTAssertTrue(item.contains(string: "6 min"))
        }

        do {
            let item = listView.itemView(withLabelStartingWith: "Item 2")
            XCTAssertTrue(item.waitForExistence())
            XCTAssertTrue(item.contains(string: "getpocket.com"))
        }
    }

    func test_2_subsequentAppLaunch_displaysCachedContent() {
        var promise: EventLoopPromise<Response>?
        server.routes.post("/") { _, loop in
            promise = loop.makePromise()
            return promise!.futureResult
        }

        app.launch()
        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let item = listView.itemView(withLabelStartingWith: "Item")
        XCTAssertTrue(item.waitForExistence())
        XCTAssertEqual(listView.itemCount, 2)

        promise?.succeed(
            Response {
                Status.ok
                Fixture.data(name: "updated-list")
            }
        )

        do {
            let item = listView.itemView(withLabelStartingWith: "Updated Item 1")
            XCTAssertTrue(item.waitForExistence())
        }

        do {
            let item = listView.itemView(withLabelStartingWith: "Updated Item 2")
            XCTAssertTrue(item.waitForExistence())
        }

        XCTAssertEqual(listView.itemCount, 2)
    }

    func test_3_tappingItem_displaysWebReaderView() {
        app.launch()

        let list = app.userListView()
        XCTAssertTrue(list.waitForExistence())

        let item = list.itemView(at: 0)
        XCTAssertTrue(item.waitForExistence())
        item.tap()

        let webReaderView = app.webReaderView()
        XCTAssertTrue(webReaderView.waitForExistence())

        let text = webReaderView.staticText(matching: "Hello, world")
        XCTAssertTrue(text.waitForExistence(timeout: 10))
    }
}
