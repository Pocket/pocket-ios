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
        return ReaderToolbarElement(element.navigationBars.element(boundBy: 0).wait())
    }

    var savesBackButton: XCUIElement {
        // This will always be a back button in the Navbar at index 0
        element.navigationBars.buttons.element(boundBy: 0).wait()
    }

    var archiveButton: XCUIElement {
        element.buttons["archiveNavButton"].wait()
    }

    var moveFromArchiveToSavesButton: XCUIElement {
        element.buttons["moveFromArchiveToSavesNavButton"].wait()
    }

    var overflowButton: XCUIElement {
        element.buttons["more"].wait()
    }

    var displaySettingsButton: XCUIElement {
        element.buttons["Display Settings"].wait()
    }

    var favoriteButton: XCUIElement {
        element.buttons["Favorite"].wait()
    }

    var addTagsButton: XCUIElement {
        element.buttons["Add Tags"].wait()
    }

    var deleteButton: XCUIElement {
        element.buttons["Delete"].wait()
    }

    var deleteNoButton: XCUIElement {
        element.buttons["No"].wait()
    }

    var deleteYesButton: XCUIElement {
        element.buttons["Yes"].wait()
    }

    var shareButton: XCUIElement {
        element.buttons["Share"].wait()
    }

    var fontButton: XCUIElement {
        element.collectionViews.cells.staticTexts["Font"].wait()
    }

    func fontSelection(fontName: String) -> XCUIElement {
        element.collectionViews.buttons[fontName].wait()
    }

    var fontStepperIncreaseButton: XCUIElement {
        element.collectionViews.steppers["Font Size"].buttons["Increment"].wait()
    }

    var fontStepperDecreaseButton: XCUIElement {
        element.collectionViews.steppers["Font Size"].buttons["Decrement"].wait()
    }

    var safariButton: XCUIElement {
        element.buttons["safari"].wait()
    }

    var safariDoneButton: XCUIElement {
        element.buttons["Done"].wait()
    }

    var readerHomeButton: XCUIElement {
        // This will always be a back button in the Navbar at index 0
        element.navigationBars.buttons.element(boundBy: 0).wait()
    }

    var unsupportedElementOpenButton: XCUIElement {
        element.buttons["Open in Web View"].wait()
    }

    var articleView: XCUIElement {
        element.collectionViews["article-view"].wait()
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
            .wait()
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
