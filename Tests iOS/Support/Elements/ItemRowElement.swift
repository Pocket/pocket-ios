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
        element
            .staticTexts
            .matching(NSPredicate(format: "label CONTAINS %@", string))
            .firstMatch
            .wait()
            .exists
    }

    var tagButton: XCUIElement {
        element.buttons["tag-button"]
    }

    func tap() {
        element
            .coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
            .tap()
    }

    var collectionLabel: XCUIElement {
        element.staticTexts["collection-label"]
    }

    var itemActionButton: XCUIElement {
        element.buttons["item-actions"]
    }

    var favoriteButton: FavoriteButton {
        FavoriteButton(element.buttons["item-action-favorite"])
    }

    var shareButton: XCUIElement {
        element.buttons["item-action-share"]
    }

    var overFlowMenu: XCUIElement {
        element.buttons["overflow-menu"]
    }
}

extension ItemRowElement {
    struct FavoriteButton: PocketUIElement {
        let element: XCUIElement

        init(_ element: XCUIElement) {
            self.element = element
        }

        var isFilled: Bool {
            element.label == "Unfavorite"
        }
    }

    struct TagButton: PocketUIElement {
        let element: XCUIElement

        init(_ element: XCUIElement) {
            self.element = element
        }

        var isFilled: Bool {
            element.label == "Unfavorite"
        }
    }
}
