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
        element.buttons["No"]
    }

    var yes: XCUIElement {
        element.buttons["Yes"]
    }

    var cancel: XCUIElement {
        element.buttons["Cancel"]
    }

    var delete: XCUIElement {
        element.buttons["Delete"]
    }

    var ok: XCUIElement {
        element.buttons["OK"]
    }

    var rename: XCUIElement {
        element.buttons["Rename"]
    }
}
