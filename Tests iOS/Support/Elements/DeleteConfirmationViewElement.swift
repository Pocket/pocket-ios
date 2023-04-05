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
        element.buttons["how-to-cancel"].wait()
    }

    var understandDeletionSwitch: XCUIElement {
        element.switches["understand-deletion"].wait()
    }

    var confirmCancelledSwitch: XCUIElement {
        element.switches["confirm-cancelled"].wait()
    }

    var deleteAccountButton: XCUIElement {
        element.buttons["delete-account"].wait()
    }

    var cancelButton: XCUIElement {
        element.buttons["cancel"].wait()
    }

    var closeButton: XCUIElement {
        element.buttons["close"].wait()
    }
}
