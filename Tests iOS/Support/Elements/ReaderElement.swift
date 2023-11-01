// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct ReaderElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var readerToolbar: ReaderToolbarElement {
        return ReaderToolbarElement(element.navigationBars.element(boundBy: 0))
    }

    var backButton: XCUIElement {
        // This will always be a back button in the Navbar at index 0
        element.navigationBars.buttons.element(boundBy: 0)
    }

    var archiveButton: XCUIElement {
        element.buttons["archiveNavButton"]
    }

    var moveFromArchiveToSavesButton: XCUIElement {
        element.buttons["moveFromArchiveToSavesNavButton"]
    }

    var overflowButton: XCUIElement {
        element.buttons["more"]
    }

    var displaySettingsButton: XCUIElement {
        element.buttons["Display settings"]
    }

    var favoriteButton: XCUIElement {
        element.buttons["Favorite"]
    }

    var addTagsButton: XCUIElement {
        element.buttons["Edit tags"]
    }

    var deleteButton: XCUIElement {
        element.buttons["Delete"]
    }

    var deleteNoButton: XCUIElement {
        element.buttons["No"]
    }

    var deleteYesButton: XCUIElement {
        element.buttons["Yes"]
    }

    var saveButton: XCUIElement {
        element.buttons["Save"]
    }

    var shareButton: XCUIElement {
        element.buttons["Share"]
    }

    var fontButton: XCUIElement {
        element.collectionViews.cells.staticTexts["Font"]
    }

    func fontSelection(fontName: String) -> XCUIElement {
        element.collectionViews.buttons[fontName]
    }

    var fontStepperIncreaseButton: XCUIElement {
        element.collectionViews.buttons["reader-settings-stepper-Increment"]
    }

    var fontStepperDecreaseButton: XCUIElement {
        element.collectionViews.buttons["reader-settings-stepper-Decrement"]
    }

    var safariButton: XCUIElement {
        element.buttons["safari"]
    }

    var safariDoneButton: XCUIElement {
        element.buttons["Done"]
    }

    var readerHomeButton: XCUIElement {
        // This will always be a back button in the Navbar at index 0
        element.navigationBars.buttons.element(boundBy: 0)
    }

    var unsupportedElementOpenButton: XCUIElement {
        element.buttons["Open in web view"]
    }

    var articleView: XCUIElement {
        element.collectionViews["article-view"]
    }

    var articleTextViews: [XCUIElement] {
        articleView.textViews.allElementsBoundByIndex
    }

    func cell(containing string: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label CONTAINS %@", string)
        return element
            .cells
            .containing(predicate)
            .element(boundBy: 0)
    }

    func scrollCellToTop(_ cell: XCUIElement) {
        let readerViewCenter = element
            .coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))

        let navbarHeight: CGFloat = 94
        let gracePixelsBeforeScrollingBegins: CGFloat = 10
        let lineSpacing: CGFloat = 8
        let dy = -cell.frame.maxY +
            navbarHeight -
            gracePixelsBeforeScrollingBegins -
            lineSpacing

        let endingPoint = readerViewCenter.withOffset(CGVector(dx: 0, dy: dy))

        readerViewCenter.press(
            forDuration: 0.1,
            thenDragTo: endingPoint,
            withVelocity: .slow,
            thenHoldForDuration: 0.1
        )
    }
}
