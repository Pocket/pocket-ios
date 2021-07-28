// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct ReaderScreen {
    private let el: XCUIElement

    init(el: XCUIElement) {
        self.el = el
    }

    func waitForExistence(timeout: TimeInterval = 1) -> Bool {
        return el.waitForExistence(timeout: timeout)
    }

    func cell(containing string: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label CONTAINS %@", string)
        return el.cells.containing(predicate).element(boundBy: 0)
    }

    func scrollCellToTop(_ cell: XCUIElement) {
        let readerViewCenter = el.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))

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
