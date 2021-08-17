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

        server.routes.post("/graphql") { _, _ in
            return Response {
                Status.ok
                Fixture
                    .load(name: "initial-list")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data
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
        
        server.routes.get("v3/guid") { _, _ in
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
        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData",
                "clearUserDefaults"
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
            XCTAssertTrue(item.contains(string: "WIRED"))
            XCTAssertTrue(item.contains(string: "6 min"))
        }

        do {
            let item = listView.itemView(withLabelStartingWith: "Item 2")
            XCTAssertTrue(item.waitForExistence())
            XCTAssertTrue(item.contains(string: "wired.com"))
        }
    }

    func test_2_subsequentAppLaunch_displaysCachedContent() {
        var promise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { _, loop in
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
                Fixture
                    .load(name: "updated-list")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data

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

    func test_3_tappingItem_displaysNativeReaderView() {
        app.launch()

        let list = app.userListView()
        XCTAssertTrue(list.waitForExistence())

        let item = list.itemView(at: 0)
        XCTAssertTrue(item.waitForExistence())
        item.tap()

        let readerView = app.readerView()
        XCTAssertTrue(readerView.waitForExistence())

        let expectedStrings = [
            "Venenatis Ridiculus Vehicula",
            "By Jacob & David",
            "Vestibulum id ligula porta felis",
            "Euismod Ipsum Mollis",
            "Maecenas faucibus mollis interdum. Etiam porta sem",
            "Dolor Pharetra Parturient Egestas",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Ornare Mollis Magna Ipsum",
            "Etiam porta sem malesuada magna mollis euismod",
            "Inline Modifiers",
            "Any text component can include inline modifiers.",
            "This paragraph contains a link a website",
            "This paragraph contains a few inline styles.",
            "Copyright Pocket 2021"
        ]

        for expectedString in expectedStrings {
            let cell = readerView.cell(containing: expectedString)
            XCTAssertTrue(cell.waitForExistence(timeout: 10))
            readerView.scrollCellToTop(cell)
        }
    }

    func test_3_webReader_displaysWebContent() {
        app.launch()

        let list = app.userListView()
        XCTAssertTrue(list.waitForExistence())

        let item = list.itemView(at: 0)
        XCTAssertTrue(item.waitForExistence())
        item.tap()

        let readerView = app.readerView()
        XCTAssertTrue(readerView.waitForExistence())

        let toolbar = app.readerToolbar()
        XCTAssertTrue(toolbar.waitForExistence())

        let webReaderButton = toolbar.webReaderButton()
        XCTAssertTrue(webReaderButton.waitForExistence(timeout: 10))
        webReaderButton.tap()

        let webView = app.webReaderView()
        XCTAssertTrue(webView.waitForExistence())
        XCTAssertTrue(webView.staticText(matching: "Hello, world").waitForExistence(timeout: 10))
    }

    func test_4_list_excludesArchivedContent() {
        server.routes.post("/graphql") { _, loop in
            Response {
                Status.ok
                Fixture
                    .load(name: "list-with-archived-item")
                    .replacing("PARTICLE_JSON", withFixtureNamed: "particle-sample", escape: .encodeJSON)
                    .data
            }
        }

        app.launch()
        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        XCTAssertEqual(listView.itemCount, 1)
        XCTAssertTrue(listView.itemView(at: 0).contains(string: "Item 2"))
    }

    func test_5_favoritingAndUnfavoritingAnItemFromList_updatesShowsFavoritedIcon_andSyncsWithServer() {
        app.launch(
            arguments: [
                "clearKeychain",
                "clearCoreData",
                "clearImageCache"
            ],
            environment: [
                "accessToken": "test-access-token"
            ]
        )

        let listView = app.userListView()
        XCTAssertTrue(listView.waitForExistence())

        let itemCell = listView.itemView(withLabelStartingWith: "Item 2")
        XCTAssertTrue(itemCell.waitForExistence(timeout: 1))
        itemCell.showActions()

        let favoriteButton = app.favoriteButton()
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 1))


        let expectRequest = expectation(description: "A request to the server")
        var favoriteRequestBody: String?
        server.routes.post("/graphql") { request, loop in
            favoriteRequestBody = body(of: request)
            expectRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "favorite")
            }
        }

        favoriteButton.tap()
        wait(for: [expectRequest], timeout: 1)


        do {
            guard let requestBody = favoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }

        let favoriteIcon = itemCell.favoriteIcon()
        XCTAssertTrue(favoriteIcon.waitForExistence(timeout: 1))

        itemCell.showActions()
        let unfavoriteButton = app.unfavoriteButton()
        XCTAssertTrue(unfavoriteButton.waitForExistence(timeout: 1))


        let expectUnfavoriteRequest = expectation(description: "A request to the server")
        var unfavoriteRequestBody: String?

        server.routes.post("/graphql") { request, loop in
            unfavoriteRequestBody = body(of: request)
            expectUnfavoriteRequest.fulfill()

            return Response {
                Status.ok
                Fixture.data(name: "unfavorite")
            }
        }

        unfavoriteButton.tap()

        wait(for: [expectUnfavoriteRequest], timeout: 1)
        XCTAssertFalse(itemCell.favoriteIcon().exists)
        do {
            guard let requestBody = unfavoriteRequestBody else {
                XCTFail("Expected request body to not be nil")
                return
            }

            XCTAssertTrue(requestBody.contains("updateSavedItemUnFavorite"))
            XCTAssertTrue(requestBody.contains("item-id-2"))
        }
    }
}
