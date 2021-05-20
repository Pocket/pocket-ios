// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct ItemElement {
    private let el: XCUIElement

    init(el: XCUIElement) {
        self.el = el
    }

    func waitForExistence(timeout: TimeInterval = 1) -> Bool {
        return el.waitForExistence(timeout: timeout)
    }

    func label() -> String {
        el.label
    }

    func tap() {
        el.tap()
    }
}
