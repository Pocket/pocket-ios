// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ReaderTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToFavoriteAnItem() {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem() {
                return Response.unfavorite()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else if apiRequest.isForItemDetail {
                return Response.itemDetail()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
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

        try server.start()
    }

    override func tearDown() async throws {
       await snowplowMicro.assertNoBadEvents()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_tappingSaves_dismissesReader_andShowsSaves() {
        launchApp_andOpenItem()
        app.readerView.savesBackButton.tap()
        app.saves.wait()
    }

    @MainActor
    func test_archivingItem_dismissesReader_andShowsSaves() async {
        launchApp_andOpenItem()
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            return Response.archive()
        }
        app.readerView.archiveButton.tap()
        app.saves.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let archiveEvent = await snowplowMicro.getFirstEvent(with: "reader.archive")
        archiveEvent!.getUIContext()!.assertHas(type: "button")
        archiveEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_moveFromArchiveToSaves_stillShowsReader() async {
        launchApp_switchToArchive_andOpenItem()
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToSaveAnItem)
            return Response.saveItem()
        }
        app.readerView.moveFromArchiveToSavesButton.tap()
        app.readerView.archiveButton.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let moveFromArchiveToSavesEvent = await snowplowMicro.getFirstEvent(with: "reader.un-archive")
        moveFromArchiveToSavesEvent!.getUIContext()!.assertHas(type: "button")
        moveFromArchiveToSavesEvent!.getContentContext()!.assertHas(url: "http://example.com/items/archived-item-1")
    }

    func test_tappingOverflowMenu_showsOverflowOptions() {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        XCTAssertTrue(app.readerView.displaySettingsButton.exists)
        XCTAssertTrue(app.readerView.favoriteButton.exists)
        XCTAssertTrue(app.readerView.addTagsButton.exists)
        XCTAssertTrue(app.readerView.deleteButton.exists)
        XCTAssertTrue(app.readerView.shareButton.exists)
    }

    func test_tappingDisplaySettings_showsDisplaySettings() {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        openDisplaySettings()
        XCTAssertTrue(app.readerView.fontStepperIncreaseButton.exists)
        XCTAssertTrue(app.readerView.fontStepperDecreaseButton.exists)
        openFontMenu()
        XCTAssertTrue(app.readerView.fontSelection(fontName: "Graphik LCG").exists)
        XCTAssertTrue(app.readerView.fontSelection(fontName: "Blanco OSF").exists)
    }

//  NOTE: Commented out for now, Daniel is unable to get these to fail locally, but they always fail in CI and on others computers.
//    func test_tappingDisplaySettings_fontStepperIncreasesFont() {
//        launchApp_andOpenItem()
//        openReaderOverflowMenu()
//        openDisplaySettings()
//
//        // XCUITests do not let us access TextView font sizes. 👎🏻
//        // So we instead grab all text views within reader mode and expect them to increase in height.
//
//        let textViews = app.readerView.articleTextViews
//        let currentHeights: [Double] = textViews.map { textElement in
//            textElement.frame.height
//        }
//        self.tapFontSizeIncreaseButton()
//        self.tapFontSizeIncreaseButton()
//        self.tapFontSizeIncreaseButton()
//
//        var i = 0
//        textViews.forEach({ text in
//            XCTAssertGreaterThan(text.frame.height, currentHeights[i], "Article text view did not grow in height")
//            i+=1
//        })
//    }
//
//    func test_tappingDisplaySettings_fontStepperDecreasesFont() {
//        launchApp_andOpenItem()
//        openReaderOverflowMenu()
//        openDisplaySettings()
//
//        // XCUITests do not let us access TextView font sizes. 👎🏻
//        // So we instead grab all text views within reader mode and expect them to decrease in height.
//
//        let textViews = app.readerView.articleTextViews
//        let currentHeights: [Double] = textViews.map { textElement in
//            textElement.frame.height
//        }
//        self.tapFontSizeDecreaseButton()
//        self.tapFontSizeDecreaseButton()
//        self.tapFontSizeDecreaseButton()
//
//        var i = 0
//        textViews.forEach({ text in
//            XCTAssertLessThan(text.frame.height, currentHeights[i], "Article text view did not shrink in height")
//            i+=1
//        })
//    }

    @MainActor
    func test_tappingWebViewButton_showsSafari() async {
        launchApp_andOpenItem()
        tapSafariButton()
        validateSafariOpens()

        let engagementEvent = await snowplowMicro.getFirstEvent(with: "reader.view_original")
        engagementEvent!.getUIContext()!.assertHas(type: "button")
        engagementEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_tappingUnsupportedElementButton_showsSafari() async {
        launchApp_andOpenItem()
        app.readerView.unsupportedElementOpenButton.wait().tap()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let impressionEvent = await snowplowMicro.getFirstEvent(with: "reader.unsupportedContent")
        impressionEvent!.getUIContext()!.assertHas(type: "card")
        impressionEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")

        validateSafariOpens()

        let engagementEvent = await snowplowMicro.getFirstEvent(with: "reader.unsupportedContent.open")
        engagementEvent!.getUIContext()!.assertHas(type: "button")
        engagementEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    func test_tappingDeleteNo_dismissesDeleteConfirmation() {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        app.readerView.wait().deleteButton.wait().tap()
        app.readerView.wait().deleteNoButton.wait().tap()
        XCTAssertTrue(app.readerView.exists)
    }

    func test_longPressingHyperlink_showsPreview_andMenu() {
        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForSavesContent {
                return Response.saves("list-for-web-view-actions")
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                return Response.fallbackResponses(apiRequest: apiRequest)
            }
        }

        app.launch().tabBar.wait().savesButton.wait().tap()

        app
            .saves
            .itemView(at: 0)
            .wait()
            .tap()

        let hyperlink = XCUIApplication()
        hyperlink.webViews.staticTexts["Hello, world"].press(forDuration: 3)
        XCTAssertTrue(hyperlink.staticTexts["Hide preview"].exists)
        XCTAssertTrue(hyperlink.buttons["Share…"].exists)
    }

    func validateSafariOpens() {
        XCTAssertTrue(app.readerView.wait().safariDoneButton.wait().exists)
    }

    func openReaderOverflowMenu() {
        app.readerView.wait().overflowButton.wait().tap()
    }

    func openDisplaySettings() {
        app.readerView.wait().displaySettingsButton.wait().tap()
    }

    func openFontMenu() {
        app.readerView.wait().fontButton.wait().tap()
    }

    func tapFontSizeIncreaseButton() {
        app.readerView.wait().fontStepperIncreaseButton.wait().tap()
    }

    func tapFontSizeDecreaseButton() {
        app.readerView.wait().fontStepperDecreaseButton.wait().tap()
    }

    func tapSafariButton() {
        app.readerView.wait().safariButton.wait().tap()
    }

    func launchApp_andOpenItem() {
        app.launch().tabBar.savesButton.wait().tap()
        app
            .saves.wait()
            .itemView(at: 0)
            .wait()
            .tap()
    }

    func launchApp_switchToArchive_andOpenItem() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.selectionSwitcher.archiveButton.tap()
        app
            .saves.wait()
            .itemView(at: 0)
            .wait()
            .tap()
    }
}
