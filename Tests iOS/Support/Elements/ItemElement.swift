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
        el.tap()
    }

    func favoriteIcon() -> XCUIElement {
        el.images["favorite"]
    }

    func showActions() {
        el.swipeLeft()
    }

    func favoriteButton() -> XCUIElement {
        el.buttons["Favorite"]
    }

    func unfavoriteButton() -> XCUIElement {
        el.buttons["Unfavorite"]
    }

    func deleteButton() -> XCUIElement {
        el.buttons["Delete"]
    }
}
