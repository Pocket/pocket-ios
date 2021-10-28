// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class Tests_iOS: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    func listResponse(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    func slateResponse() -> Response {
        Response {
            Status.ok
            Fixture.data(name: "slates")
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                return self.listResponse()
            }
        }

        server.routes.post("/v3/oauth/authorize") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content: Fixture.data(name: "successful-auth")
            )
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }
        
        server.routes.get("/v3/guid") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content: Fixture.data(name: "guid")
            )
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_1_signingIn_whenSigninIsSuccessful_showsUserList() {
        app.launch(environment: LaunchEnvironment(accessToken: nil, sessionGUID: nil, sessionUserID: nil))

        let signInView = app.signInView.wait()

        signInView.emailField.tap()
        app.typeText("test@example.com")
        signInView.passwordField.tap()
        app.typeText("super-secret-password")
        signInView.signInButton.tap()

        app.tabBar.myListButton.wait().tap()
        let listView = app.userListView.wait()

        do {
            let item = listView
                .itemView(withLabelStartingWith: "Item 1")
                .wait()

            XCTAssertTrue(item.contains(string: "WIRED"))
            XCTAssertTrue(item.contains(string: "6 min"))
        }

        do {
            let item = listView
                .itemView(withLabelStartingWith: "Item 2")
                .wait()

            XCTAssertTrue(item.contains(string: "wired.com"))
        }
    }

    func test_2_subsequentAppLaunch_displaysCachedContent() {
        var promise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, loop in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                promise = loop.makePromise()
                return promise!.futureResult
            }
        }

        app.launch(
            arguments: LaunchArguments(
                clearKeychain: false,
                clearCoreData: false
            )
        ).tabBar.myListButton.wait().tap()
        let listView = app.userListView.wait()

        listView
            .itemView(withLabelStartingWith: "Item")
            .wait()

        XCTAssertEqual(listView.itemCount, 2)

        promise?.succeed(
            Response {
                Status.ok
                Fixture.data(name: "updated-list")
            }
        )

        do {
            listView
                .itemView(withLabelStartingWith: "Updated Item 1")
                .wait()
        }

        do {
            listView
                .itemView(withLabelStartingWith: "Updated Item 2")
                .wait()
        }

        XCTAssertEqual(listView.itemCount, 2)
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.myListButton.wait().tap()

        app
            .userListView
            .itemView(at: 0)
            .wait()
            .tap()

        let expectedMetadataStrings = [
            "Item 1",
            "by Jacob and David",
            "WIRED",
            "January 1, 2021",
        ]

        for expectedString in expectedMetadataStrings {
            let cell = app
                .readerView
                .cell(containing: expectedString)
                .wait()

            app.readerView.scrollCellToTop(cell)
        }
        
        var cell = app
            .readerView
            .cell(containing: "Commodo Consectetur Dapibus")
            .wait()
        app.readerView.scrollCellToTop(cell)
        
        cell = app
            .readerView
            .cell(containing: "Purus Vulputate")
            .wait()
        app.readerView.scrollCellToTop(cell)
    }

    func test_webReader_displaysWebContent() {
        app.launch().tabBar.myListButton.wait().tap()

        app
            .userListView
            .itemView(at: 0)
            .wait()
            .tap()

        app
            .readerView
            .readerToolbar
            .webReaderButton
            .wait()
            .tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()
    }

    func test_list_excludesArchivedContent() {
        server.routes.post("/graphql") { request, _ in
            let requestBody = body(of: request)

            if requestBody!.contains("getSlateLineup")  {
                return self.slateResponse()
            } else {
                return self.listResponse("list-with-archived-item")
            }
        }

        app.launch().tabBar.myListButton.wait().tap()

        let listView = app.userListView.wait()
        listView.itemView(at: 0).wait()

        XCTAssertEqual(listView.itemCount, 1)
        XCTAssertTrue(listView.itemView(at: 0).contains(string: "Item 2"))
    }
}
