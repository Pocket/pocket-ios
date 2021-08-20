// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct UserListElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var itemCount: Int {
        element.cells.count
    }

    func itemView(at index: Int) -> ItemRowElement {
        return ItemRowElement(element.cells.element(boundBy: index))
    }

    func itemView(withLabelStartingWith string: String) -> ItemRowElement {
        let predicate = NSPredicate(format: "label BEGINSWITH %@", string)
        return ItemRowElement(element.cells.element(matching: predicate))
    }

    func pullToRefresh() {
        let centerCenter = CGVector(dx: 0.5, dy: 0.8)

        element.cells
            .element(boundBy: 0)
            .coordinate(withNormalizedOffset: centerCenter)
            .press(
                forDuration: 0.1,
                thenDragTo: element.coordinate(
                    withNormalizedOffset: centerCenter
                )
            )
    }
}
