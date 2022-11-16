// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct AccountViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var signOutButton: XCUIElement {
        element.buttons["sign-out-button"]
    }

}
