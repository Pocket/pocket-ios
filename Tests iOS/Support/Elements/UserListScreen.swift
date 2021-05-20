// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct UserListScreen {
    private let el: XCUIElement

    init(el: XCUIElement) {
        self.el = el
    }

    func waitForExistence(timeout: TimeInterval = 1) -> Bool {
        return el.waitForExistence(timeout: timeout)
    }

    func itemView(at index: Int) -> ItemElement {
        return ItemElement(el: el.cells.element(boundBy: index))
    }

    func itemView(withLabelStartingWith string: String) -> ItemElement {
        let predicate = NSPredicate(format: "label BEGINSWITH %@", string)
        return ItemElement(el: el.cells.element(matching: predicate))
    }

    var itemCount: Int {
        el.cells.count
    }
}
