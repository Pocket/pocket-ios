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
        try await super.setUp()
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

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

        try server.start()
    }

    @MainActor
    override func tearDown() async throws {
        app.terminate()
        await snowplowMicro.assertBaselineSnowplowExpectation()
        try server.stop()
        try await super.tearDown()
    }

    func test_tappingSaves_dismissesReader_andShowsSaves() {
        launchApp_andOpenItem()
        app.readerView.backButton.tap()
        app.saves.wait()
    }

    @MainActor
    func test_archivingItem_dismissesReader_andShowsSaves() async {
        let archiveExpectation = expectation(description: "Did archive an item")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToArchiveAnItem {
                defer { archiveExpectation.fulfill() }
                return .archive(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        launchApp_andOpenItem()
        app.readerView.archiveButton.tap()
        wait(for: [archiveExpectation])
        app.saves.wait()

        let archiveEvent = await snowplowMicro.getFirstEvent(with: "reader.archive")
        archiveEvent!.getUIContext()!.assertHas(type: "button")
        archiveEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_moveFromArchiveToSaves_stillShowsReader() async {
        let saveExpectation = expectation(description: "Did save an item")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                defer { saveExpectation.fulfill() }
                return .saveItem(apiRequest: apiRequest)
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
        launchApp_switchToArchive_andOpenItem()
        app.readerView.moveFromArchiveToSavesButton.tap()
        wait(for: [saveExpectation])
        app.readerView.archiveButton.wait()

        let moveFromArchiveToSavesEvent = await snowplowMicro.getFirstEvent(with: "reader.un-archive")
        moveFromArchiveToSavesEvent!.getUIContext()!.assertHas(type: "button")
        moveFromArchiveToSavesEvent!.getContentContext()!.assertHas(url: "http://example.com/items/archived-item-1")
    }

    @MainActor
    func test_tappingOverflowMenu_showsOverflowOptions() async {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        XCTAssertTrue(app.readerView.displaySettingsButton.exists)
        XCTAssertTrue(app.readerView.favoriteButton.exists)
        XCTAssertTrue(app.readerView.addTagsButton.exists)
        XCTAssertTrue(app.readerView.deleteButton.exists)
        XCTAssertTrue(app.readerView.shareButton.exists)

        let overflowEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.overflow")
        overflowEvent!.getUIContext()!.assertHas(type: "button")
        overflowEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_tappingDisplaySettings_showsDisplaySettings() async {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        openDisplaySettings()
        XCTAssertTrue(app.readerView.fontStepperIncreaseButton.exists)
        XCTAssertTrue(app.readerView.fontStepperDecreaseButton.exists)
        openFontMenu()
        XCTAssertTrue(app.readerView.fontSelection(fontName: "Graphik").exists)
        XCTAssertTrue(app.readerView.fontSelection(fontName: "Blanco").exists)

        let textSettingsEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.text_settings")
        textSettingsEvent!.getUIContext()!.assertHas(type: "button")
        textSettingsEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_tappingSave_savesItem() async {
        app.launch()

        // Swipe down to a syndicated item
        scrollTo(element: app.homeView.recommendationCell("Slate 1, Recommendation 2").element, in: app.homeView.element, direction: .up)
        app.homeView.recommendationCell("Slate 1, Recommendation 2").wait().tap()
        app.readerView.readerToolbar.moreButton.wait().tap()
        app.readerView.saveButton.wait().tap()

        app.readerView.backButton.wait().tap()
        app.tabBar.savesButton.wait().tap()
        app.saves.itemView(matching: "Slate 1, Recommendation 2").wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let reportEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.save")
        reportEvent!.getUIContext()!.assertHas(type: "button")
        reportEvent!.getContentContext()!.assertHas(url: "https://getpocket.com/explore/item/article-2")
    }

    func test_tappingDisplaySettings_fontStepperIncreasesFont() {
        // Given
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        openDisplaySettings()

        // XCUITests do not let us access TextView font sizes. 👎🏻
        // So we instead grab all text views within reader mode and expect them to increase in height.

        let textViews = app.readerView.articleTextViews
        let oldTextView = textViews.first!
        let oldText = oldTextView.value as! String
        let oldHeight = oldTextView.frame.height

        // When
        self.tapFontSizeIncreaseButton()
        self.tapFontSizeIncreaseButton()
        self.tapFontSizeIncreaseButton()

        // Then
        let newTextView = textViews.first!
        let newText = newTextView.value as! String
        let newHeight = newTextView.frame.height
        // ensure we are grabbing the same textview
        XCTAssertEqual(oldText, newText)
        // then ensure the textview has increased height
        XCTAssertGreaterThan(newHeight, oldHeight)
    }

    func test_tappingDisplaySettings_fontStepperDecreasesFont() {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        openDisplaySettings()

        // XCUITests do not let us access TextView font sizes. 👎🏻
        // So we instead grab all text views within reader mode and expect them to decrease in height.

        let textViews = app.readerView.articleTextViews
        let currentHeights: [Double] = textViews.map { textElement in
            textElement.frame.height
        }
        self.tapFontSizeDecreaseButton()
        self.tapFontSizeDecreaseButton()
        self.tapFontSizeDecreaseButton()

        var i = 0
        textViews.forEach({ text in
            XCTAssertLessThan(text.frame.height, currentHeights[i], "Article text view did not shrink in height")
            i+=1
        })
    }

    @MainActor
    func test_tappingWebViewButton_showsSafari() async {
        launchApp_andOpenItem()
        tapSafariButton()
        validateSafariOpens()

        let engagementEvent = await snowplowMicro.getFirstEvent(with: "reader.view-original")
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

    @MainActor
    func test_tappingDeleteNo_dismissesDeleteConfirmation() async {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        app.readerView.wait().deleteButton.wait().tap()
        app.readerView.wait().deleteNoButton.wait().tap()
        XCTAssertTrue(app.readerView.exists)
    }

    func test_longPressingHyperlink_showsPreview_andMenu() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSavesContent {
                return .saves("list-for-web-view-actions")
            }
            return .fallbackResponses(apiRequest: apiRequest)
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
