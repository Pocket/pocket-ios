// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct TagsFilterViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var editButton: XCUIElement {
        element.buttons["edit-button"]
    }

    var renameButton: XCUIElement {
        element.buttons["rename-button"]
    }

    var deleteButton: XCUIElement {
        element.buttons["delete-button"]
    }

    func tag(matching string: String) -> XCUIElement {
        return element.staticTexts[string].self
    }

    var tagCells: XCUIElementQuery {
        element.cells.staticTexts.matching(identifier: "all-tags")
    }

    var recentTagCells: XCUIElementQuery {
        element.cells.staticTexts.matching(identifier: "recent-tags")
    }

    func tagCells(matching string: String) -> XCUIElement {
        return tagCells.containing(
            .staticText,
            identifier: string
        ).element(boundBy: 0)
    }
}
