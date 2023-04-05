// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct AlertElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var no: XCUIElement {
        element.buttons["No"].wait()
    }

    var yes: XCUIElement {
        element.buttons["Yes"].wait()
    }

    var cancel: XCUIElement {
        element.buttons["Cancel"].wait()
    }

    var delete: XCUIElement {
        element.buttons["Delete"].wait()
    }

    var ok: XCUIElement {
        element.buttons["OK"].wait()
    }
}
