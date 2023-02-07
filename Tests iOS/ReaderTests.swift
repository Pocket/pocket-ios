// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ReaderTests: XCTestCase {
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
            } else if apiRequest.isForSavesContent {
                return Response.saves()
            } else if apiRequest.isForArchivedContent {
                return Response.archivedContent()
            } else if apiRequest.isToFavoriteAnItem {
                return Response.favorite()
            } else if apiRequest.isToUnfavoriteAnItem {
                return Response.unfavorite()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()
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

    func test_archivingItem_dismissesReader_andShowsSaves() {
        launchApp_andOpenItem()
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            XCTAssertTrue(apiRequest.isToArchiveAnItem)
            return Response.archive()
        }
        app.readerView.archiveButton.tap()
        app.saves.wait()
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

    func test_tappingWebViewButton_showsSafari() {
        launchApp_andOpenItem()
        tapSafariButton()
        validateSafariOpens()
    }

    func test_tappingUnsupportedElementButton_showsSafari() {
        launchApp_andOpenItem()
        app.readerView.unsupportedElementOpenButton.tap()
        validateSafariOpens()
    }

    func test_tappingDeleteNo_dismissesDeleteConfirmation() {
        launchApp_andOpenItem()
        openReaderOverflowMenu()
        app.readerView.deleteButton.tap()
        app.readerView.deleteNoButton.tap()
        XCTAssertTrue(app.readerView.exists)
    }

    func test_longPressingHyperlink_showsPreview_andMenu() {
        launchApp_andOpenItem()
        scrollDownToHyperlink()
        let hyperlink = XCUIApplication()
        hyperlink.collectionViews.staticTexts["Pocket: The place to absorb great content."].press(forDuration: 3)
        XCTAssertTrue(hyperlink.staticTexts["Hide preview"].exists)
        XCTAssertTrue(hyperlink.buttons["Share…"].exists)
    }

    func validateSafariOpens() {
        XCTAssertTrue(app.readerView.safariDoneButton.exists)
    }

    func openReaderOverflowMenu() {
        app.readerView.overflowButton.tap()
    }

    func openDisplaySettings() {
        app.readerView.displaySettingsButton.tap()
    }

    func openFontMenu() {
        app.readerView.fontButton.tap()
    }

    func tapFontSizeIncreaseButton() {
        app.readerView.fontStepperIncreaseButton.tap()
    }

    func tapFontSizeDecreaseButton() {
        app.readerView.fontStepperDecreaseButton.tap()
    }

    func tapSafariButton() {
        app.readerView.safariButton.tap()
    }

    func launchApp_andOpenItem() {
        app.launch().tabBar.savesButton.wait().tap()
        app
            .saves
            .itemView(at: 0)
            .wait()
            .tap()
    }

    func scrollDownToHyperlink() {
        let reader = XCUIApplication()
        reader.swipeUp()
    }
}
