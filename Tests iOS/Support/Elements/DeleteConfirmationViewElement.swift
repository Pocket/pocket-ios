// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

import XCTest

struct DeleteConfirmationViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var howToDeleteButton: XCUIElement {
        element.buttons["how-to-cancel"]
    }

    var understandDeletionSwitch: XCUIElement {
        element.switches["understand-deletion"]
    }

    var confirmCancelledSwitch: XCUIElement {
        element.switches["confirm-cancelled"]
    }

    var deleteAccountButton: XCUIElement {
        element.buttons["delete-account"]
    }

    var cancelButton: XCUIElement {
        element.buttons["cancel"]
    }

    var closeButton: XCUIElement {
        element.buttons["close"]
    }
}
