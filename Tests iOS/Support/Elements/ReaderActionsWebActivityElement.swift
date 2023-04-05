// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct ReaderActionsWebActivityElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    func activityOption(_ label: String) -> XCUIElement {
        if #available(iOS 16.4, *) {
            // Note that pre iOS 16.4 these were buttons, they now are StaticTexts
            return element.staticTexts[label].wait()
        } else {
            return element.buttons[label].wait()
        }
    }
}
