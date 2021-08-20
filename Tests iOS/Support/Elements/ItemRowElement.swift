// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct ItemRowElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    func contains(string: String) -> Bool {
        element.label.contains(string)
    }

    func tap() {
        element
            .coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
            .tap()
    }

    var favoriteIcon: XCUIElement {
        element.images["favorite"]
    }

    var itemActionButton: XCUIElement {
        element.buttons.element(boundBy: 1)
    }
}
