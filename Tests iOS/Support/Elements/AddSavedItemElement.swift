// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct AddSavedItemElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var addItemButton: XCUIElement {
        element.buttons["add_item_button"]
    }

    var cancelButton: XCUIElement {
        element.buttons["cancel_button"]
    }

    var closeButton: XCUIElement {
        element.buttons["close_button"]
    }

    var urlEntryTextField: XCUIElement {
        element.textFields["url_textfield"]
    }

    var errorMessage: XCUIElement {
        element.staticTexts["error_message"]
    }
}
