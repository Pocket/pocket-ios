// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct AddTagsViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var saveButton: XCUIElement {
        element.buttons["save-button"]
    }

    var newTagTextField: XCUIElement {
        element.textFields["enter-tag-name"]
    }

    var allTagsView: XCUIElement {
        element.collectionViews["all-tags"]
    }

    func allTagsRow(matching string: String) -> XCUIElement {
        return allTagsView.staticTexts[string].self
    }

    func tag(matching string: String) -> XCUIElement {
        return element.staticTexts[string].self
    }
}
