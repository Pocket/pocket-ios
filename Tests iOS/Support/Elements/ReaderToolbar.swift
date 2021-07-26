// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct ReaderToolbar {
    let el: XCUIElement

    func webReaderButton() -> XCUIElement {
        return el.buttons["safari"]
    }

    func waitForExistence() -> Bool {
        return el.waitForExistence(timeout: 1)
    }
}
