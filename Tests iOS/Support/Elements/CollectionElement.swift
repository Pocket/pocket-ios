// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct CollectionElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var backButton: XCUIElement {
        element.navigationBars.buttons.element(boundBy: 0)
    }

    var archiveButton: XCUIElement {
        element.buttons["archiveNavButton"]
    }

    var savesButton: XCUIElement {
        element.buttons["savesNavButton"]
    }

    var overflowButton: XCUIElement {
        element.buttons["moreButton"]
    }

    var favoriteButton: XCUIElement {
        element.buttons["Favorite"]
    }

    var unfavoriteButton: XCUIElement {
        element.buttons["Unfavorite"]
    }

    var addTagsButton: XCUIElement {
        element.buttons["Edit tags"]
    }

    var deleteButton: XCUIElement {
        element.buttons["Delete"]
    }

    var deleteNoButton: XCUIElement {
        element.buttons["No"]
    }

    var deleteYesButton: XCUIElement {
        element.buttons["Yes"]
    }

    var shareButton: XCUIElement {
        element.buttons["Share"]
    }

    var reportButton: XCUIElement {
        element.buttons["Report"]
    }

    func cell(containing string: String) -> RecommendationCellElement {
        let predicate = NSPredicate(format: "label CONTAINS %@", string)
        let element = element
            .cells
            .containing(predicate)
            .element(boundBy: 0)
        return RecommendationCellElement(element)
    }
}
