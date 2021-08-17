// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct ItemElement {
    private let el: XCUIElement

    init(el: XCUIElement) {
        self.el = el
    }

    var exists: Bool {
        el.exists
    }

    func waitForExistence(timeout: TimeInterval = 1) -> Bool {
        return el.waitForExistence(timeout: timeout)
    }

    func label() -> String {
        el.label
    }

    func contains(string: String) -> Bool {
        return el.label.contains(string)
    }

    func tap() {
        let vector = CGVector(dx: 0.1, dy: 0.1)
        el.coordinate(withNormalizedOffset: vector).tap()
    }

    func favoriteIcon() -> XCUIElement {
        el.images["favorite"]
    }

    func showActions() {
        let button = el.buttons.element(boundBy: 1)
        XCTAssertTrue(button.waitForExistence(timeout: 1))

        button.tap()
    }
}
