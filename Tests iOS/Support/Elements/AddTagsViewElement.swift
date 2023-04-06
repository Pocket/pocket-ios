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
        let query: XCUIElementQuery

        if #available(iOS 16, *) {
            query = element.collectionViews
        } else {
            query = element.tables
        }

        return query["all-tags"].wait()
    }

    func allTagsRow(matching string: String) -> XCUIElement {
        return allTagsView.staticTexts[string]
    }

    func tag(matching string: String) -> XCUIElement {
        return element.staticTexts[string]
    }

    func clearTagsTextfield() {
        newTagTextField.tap()
        newTagTextField.typeText(XCUIKeyboardKey.delete.rawValue)
    }

    @discardableResult
    func enterRandomTagName() -> String {
        let randomInt = Int.random(in: 1..<155)
        let tagInt = String(randomInt)
        newTagTextField.typeText(tagInt)
        newTagTextField.typeText("\n")
        return tagInt
    }
}
