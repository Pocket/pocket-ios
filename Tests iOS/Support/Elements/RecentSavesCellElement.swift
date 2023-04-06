// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct RecentSavesCellElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var favoriteButton: FavoriteButton {
        FavoriteButton(element.buttons["item-action-favorite"])
    }

    var overflowButton: XCUIElement {
        element.buttons["overflow-button"]
    }
}

extension RecentSavesCellElement {
    struct FavoriteButton: PocketUIElement {
        let element: XCUIElement

        init(_ element: XCUIElement) {
            self.element = element
        }

        var isFilled: Bool {
            element.label == "Unfavorite"
        }
    }
}
