// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct RecommendationCellElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var saveButton: XCUIElement {
        element.buttons["Save"]
    }

    var savedButton: XCUIElement {
        element.buttons["Saved"]
    }

    var overflowButton: XCUIElement {
        element.buttons["overflow-button"]
    }

    var collectionLabel: XCUIElement {
        element.staticTexts["collection-label"]
    }

    struct SaveButton: PocketUIElement {
        let element: XCUIElement

        init(_ element: XCUIElement) {
            self.element = element
        }

        var isSaved: Bool {
            element.label == "Saved"
        }
    }
}
