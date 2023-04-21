// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class SavesTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        server.routes.get("/hello/item-1") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        server.routes.get("/new-item") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        server.routes.get("/welcome") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "welcome", ext: "html")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_savingAnItemFromShareExtension_addsItemToList() {
        let saveExpectation = expectation(description: "Saved an item from the extension")
        server.routes.post("/graphql") { request, eventLoop -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isToSaveAnItem {
                defer { saveExpectation.fulfill() }
                return .saveItemFromExtension()
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(at: 0).wait()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        safari.textFields["Address"].tap()
        safari.typeText("http://localhost:8080/new-item\n")
        safari.staticTexts["Hello, world"].wait()
        safari.toolbars.buttons["ShareButton"].tap()

        let activityView = safari.descendants(matching: .other)["ActivityListView"].wait()

        // Sadly this is the only way I could devise to find the Pocket Beta button
        // This will likely be very brittle
        activityView.cells.matching(identifier: "XCElementSnapshotPrivilegedValuePlaceholder").element(boundBy: 1).tap()
        safari.staticTexts["Saved to Pocket"].wait()

        app.activate()
        wait(for: [saveExpectation])
        app.saves.itemView(matching: "Item 3").wait()
    }

    func test_tappingItem_displaysNativeReaderView() {
        app.launch().tabBar.savesButton.wait().tap()

        app
            .saves
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
            guard app.readerView.cell(containing: expectedString).isHittable else {
                app.readerView.element.swipeUp()
                let cell = app.readerView.cell(containing: expectedString).wait()
                app.readerView.scrollCellToTop(cell)
                XCTAssertTrue(cell.exists)
                return
            }
        }
    }

    func test_webReader_displaysWebContent() {
        app.launch().tabBar.savesButton.wait().tap()

        app
            .saves
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
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .saves("list-with-archived-item")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.itemView(at: 0).wait()

        XCTAssertEqual(listView.itemCount, 1)
        XCTAssertTrue(listView.itemView(at: 0).contains(string: "Item 2"))
    }

    func test_list_showsSkeletonCellsDuringInitialFetch() {
        continueAfterFailure = true
        var savesCalls = 0
        let saves1Expectation = expectation(description: "saves page 1")
        let saves2Expectation = expectation(description: "saves page 2")
        var save1Promise: EventLoopPromise<Response>?
        var save2Promise: EventLoopPromise<Response>?

        server.routes.post("/graphql") { request, eventLoop -> FutureResponse in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                defer { savesCalls += 1 }
                switch savesCalls {
                case 0:
                    defer { saves1Expectation.fulfill() }
                    save1Promise = eventLoop.makePromise()
                    return save1Promise!.futureResult
                default:
                    defer { saves2Expectation.fulfill() }
                    save2Promise = eventLoop.makePromise()
                    return save2Promise!.futureResult
                }
            }
            return Response.fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.skeletonCell(at: 0).wait()
        listView.skeletonCell(at: 1).wait()
        listView.skeletonCell(at: 2).wait()
        listView.skeletonCell(at: 3).wait()
        XCTAssertEqual(listView.itemCount, 0)
        XCTAssertEqual(listView.skeletonCellCount, 4)
        save1Promise!.completeWith(.success(.saves("saves-loading-page-1")))
        wait(for: [saves1Expectation])

        listView.itemView(at: 0).wait()
        listView.itemView(at: 1).wait()
        listView.skeletonCell(at: 0).wait()
        XCTAssertEqual(listView.itemCount, 2)
        XCTAssertEqual(listView.skeletonCellCount, 1)
        save2Promise!.completeWith(.success(.saves("saves-loading-page-2")))
        wait(for: [saves2Expectation])

        listView.itemView(at: 0).wait()
        listView.itemView(at: 1).wait()
        listView.itemView(at: 2).wait()
        XCTAssertEqual(listView.itemCount, 3)
        XCTAssertEqual(listView.skeletonCellCount, 0)
    }

    // MARK: - Saves: Sort Items
    func test_selectingANewSortOrder_SortItems() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(matching: "Item 1").wait()

        app.saves.filterButton(for: "All").swipeLeft()
        app.saves.filterButton(for: "Sort/Filter").wait().tap()
        app.sortMenu.sortOption("Oldest saved").wait().tap()

        app.saves.itemView(matching: "Item 1").wait()
        XCTAssertTrue(app.saves.itemView(at: 0).contains(string: "Item 2"))
        XCTAssertTrue(app.saves.itemView(at: 1).contains(string: "Item 1"))

        app.saves.filterButton(for: "Sort/Filter").wait().tap()
        app.sortMenu.sortOption("Newest saved").wait().tap()

        XCTAssertTrue(app.saves.itemView(at: 0).contains(string: "Item 1"))
        XCTAssertTrue(app.saves.itemView(at: 1).contains(string: "Item 2"))
    }

    func test_tappingTagLabel_showsTagFilter() {
        app.launch().tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        XCTAssertEqual(listView.itemCount, 2)
        let item = listView.itemView(at: 1)
        XCTAssertTrue(item.tagButton.firstMatch.label == "filter tag 0")
        XCTAssertTrue(item.contains(string: "+3"))
        item.tagButton.firstMatch.tap()
        app.saves.selectedTagChip(for: "filter tag 0").wait()
    }
}

// MARK: - Web View

extension SavesTests {
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
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSavesContent {
                return .saves("list-for-web-view")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(at: index)
            .wait()
            .tap()

        app
            .webReaderView
            .wait()
    }

    func test_webview_includesCustomItemActions() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

           if apiRequest.isForSavesContent {
               return .saves("list-for-web-view-actions")
           }
           return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(at: 0)
            .wait()
            .tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()

        app.shareButton.tap()

        app
            .readerActionWebActivity
            .activityOption("Archive")
            .wait()

        app
            .readerActionWebActivity
            .activityOption("Delete")
            .wait()

        app
            .readerActionWebActivity
            .activityOption("Favorite")
            .wait()
    }

    func test_webview_validateCustomItemActions_whenNavigateToAnotherPage() {
        test_list_showsWebView(at: 0)

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()
            .tap()

        app
            .webReaderView
            .staticText(matching: "Welcome")
            .wait()

        app
            .shareButton
            .wait()
            .tap()

        waitForDisappearance(
            of: app
                .readerActionWebActivity
                .activityOption("Save")
        )

        waitForDisappearance(
            of: app
                .readerActionWebActivity
                .activityOption("Archive")
        )

        waitForDisappearance(
            of: app
                .readerActionWebActivity
                .activityOption("Delete")
        )

        waitForDisappearance(
            of: app
                .readerActionWebActivity
                .activityOption("Favorite")
        )
    }
}
