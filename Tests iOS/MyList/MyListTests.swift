// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class MyListTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else {
                fatalError("Unexpected request")
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

//    func test_1_signingIn_whenSigninIsSuccessful_showsUserList() {
//        app.launch(arguments: .firstLaunch, environment: .noSession)
//
//        let signInView = app.signInView.wait()
//
//        signInView.emailField.tap()
//        app.typeText("test@example.com")
//        signInView.passwordField.tap()
//        app.typeText("super-secret-password")
//        signInView.signInButton.tap()
//
//        app.tabBar.myListButton.wait().tap()
//        let listView = app.myListView.wait()
//
//        do {
//            let item = listView
//                .itemView(matching: "Item 1")
//                .wait()
//
//            XCTAssertTrue(item.contains(string: "WIRED"))
//            XCTAssertTrue(item.contains(string: "6 min"))
//        }
//
//        do {
//            let item = listView
//                .itemView(matching: "Item 2")
//                .wait()
//
//            XCTAssertTrue(item.contains(string: "wired.com"))
//        }
//    }
//
//    func test_2_subsequentAppLaunch_displaysCachedContent() {
//        var promise: EventLoopPromise<Response>?
//        server.routes.post("/graphql") { request, loop in
//            let apiRequest = ClientAPIRequest(request)
//
//            if apiRequest.isForSlateLineup {
//                return Response.slateLineup()
//            } else if apiRequest.isForArchivedContent {
//                return Response.archivedContent()
//            } else if apiRequest.isForMyListContent {
//                promise = loop.makePromise()
//                return promise!.futureResult
//            } else {
//                fatalError("Unexpected request")
//            }
//        }
//
//        app.launch(
//            arguments: .preserve,
//            environment: .noSession
//        ).tabBar.myListButton.wait().tap()
//
//        let listView = app.myListView.wait()
//        ["Item 1", "Item 2"].forEach { label in
//            listView.itemView(matching: label).wait()
//        }
//        XCTAssertEqual(listView.itemCount, 2)
//
//        promise?.succeed(Response.myList("updated-list"))
//        ["Updated Item 1", "Updated Item 2"].forEach { label in
//            listView.itemView(matching: label).wait()
//        }
//        XCTAssertEqual(listView.itemCount, 2)
//    }

    func test_savingAnItemFromShareExtension_addsItemToList() {
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.itemView(at: 0).wait()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/hello\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()
        let activityView = safari.descendants(matching: .other)["ActivityListView"].wait()

        var promise: EventLoopPromise<Response>?
        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                promise = eventLoop.makePromise()
                return promise!.futureResult
            } else if apiRequest.isForMyListContent {
                return Response.myList()
            }
            else {
                fatalError("Unexpected request")
            }
        }

        // Sadly this is the only way I could devise to find the Pocket Beta button
        // This will likely be very brittle
        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
        safari.staticTexts["Saved to Pocket"].wait()

        let x = expectation(description: "ya")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            x.fulfill()
        }
        wait(for: [x], timeout: 4)

        app.activate()
        app.myListView.itemView(matching: "http://localhost:8080/hello").wait()

        promise?.succeed(.saveItemFromExtension())
        app.myListView.itemView(matching: "Item 3").wait(timeout: 10000)
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(at: 0)
            .wait()
            .tap()

        let expectedContent = [
            "Item 1",
            "Jacob and David",
            "WIRED",
            "January 1, 2021",
            
            "Commodo Consectetur Dapibus",
            
            "Purus Vulputate",
            
            "Nulla vitae elit libero, a pharetra augue. Cras justo odio, dapibus ac facilisis in, egestas eget quam.",
            "Photo by: Bibendum Vestibulum Mollis",
            
            "<some></some><code></code>",
            
            "• Pharetra Dapibus Ultricies",
            "• netus et malesuada",
            "• quis commodo odio",
            "• tincidunt ornare massa",
            
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
            .myListView
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
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList("list-with-archived-item")
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else {
                fatalError("Unexpected request")
            }
        }

        app.launch().tabBar.myListButton.wait().tap()

        let listView = app.myListView.wait()
        listView.itemView(at: 0).wait()

        XCTAssertEqual(listView.itemCount, 1)
        XCTAssertTrue(listView.itemView(at: 0).contains(string: "Item 2"))
    }


}

// MARK: - Web View

extension MyListTests {
    func test_list_showsWebViewWhenItemIsImage() {
        test_list_showsWebView(at: 0)
    }

    func test_list_showsWebViewWhenItemIsVideo() {
        test_list_showsWebView(at: 1)
    }

    func test_list_showsWebViewWhenItemIsNotAnArticle() {
        test_list_showsWebView(at: 2)
    }

    func test_list_showsWebView(at index: Int) {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList("list-for-web-view")
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else {
                fatalError("Unexpected request")
            }
        }

        app.launch().tabBar.myListButton.wait().tap()

        app
            .myListView
            .itemView(at: index)
            .wait()
            .tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()
    }
}
