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
        app.launch(arguments: .firstLaunch, environment: .noSession)

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
            arguments: .preserve,
            environment: .noSession
        ).tabBar.myListButton.wait().tap()

        let listView = app.userListView.wait()
        ["Item 1", "Item 2"].forEach { label in
            listView.itemView(withLabelStartingWith: label).wait()
        }
        XCTAssertEqual(listView.itemCount, 2)

        promise?.succeed(
            Response {
                Status.ok
                Fixture.data(name: "updated-list")
            }
        )

        ["Updated Item 1", "Updated Item 2"].forEach { label in
            listView.itemView(withLabelStartingWith: label).wait()
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

        let expectedContent = [
            "Item 1",
            "by Jacob and David",
            "WIRED",
            "January 1, 2021",
            
            "Commodo Consectetur Dapibus",
            
            "Purus Vulputate",
            
            "Nulla vitae elit libero, a pharetra augue. Cras justo odio, dapibus ac facilisis in, egestas eget quam.",
            "Photo by: Bibendum Vestibulum Mollis",
            
            "<some></some><code></code>",
            
            "• Pharetra Dapibus Ultricies",
            "◦ netus et malesuada",
            "▪\u{fe0e} quis commodo odio",
            "▪\u{fe0e} tincidunt ornare massa",
            
            "1. Amet Commodo Fringilla",
            "2. nunc sed augue",
            
            "This element is currently unsupported.",
            
            "Pellentesque Ridiculus Porta"
        ]

        for expectedString in expectedContent {
            let cell = app
                .readerView
                .cell(containing: expectedString)
                .wait()

            app.readerView.scrollCellToTop(cell)
        }
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
