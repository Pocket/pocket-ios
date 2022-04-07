// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct MyListElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var selectionSwitcher: SelectionSwitcherElement {
        return SelectionSwitcherElement(element.otherElements["my-list-selection-switcher"])
    }

    private var collectionView: XCUIElement {
        element.otherElements["my-list"].collectionViews.firstMatch
    }

    var itemCells: XCUIElementQuery {
        collectionView.cells.matching(NSPredicate(format: "identifier = %@", "my-list-item"))
    }

    var favoritesButton: XCUIElement {
        collectionView.cells.matching(
            NSPredicate(
                format: "identifier = %@",
                "topic-chip"
            )
        ).containing(.staticText, identifier: "Favorites").element(boundBy: 0)
    }

    var archiveSwipeButton: XCUIElement {
        collectionView.buttons["Archive"]
    }

    var readdSwipeButton: XCUIElement {
        collectionView.buttons["Move to My List"]
    }

    var itemCount: Int {
        itemCells.count
    }

    func itemView(at index: Int) -> ItemRowElement {
        return ItemRowElement(itemCells.element(boundBy: index))
    }

    func itemView(matching string: String) -> ItemRowElement {
        let cell = itemCells.containing(
            .staticText,
            identifier: string
        ).element(boundBy: 0)

        return ItemRowElement(cell)
    }

    func pullToRefresh() {
        let centerCenter = CGVector(dx: 0.5, dy: 0.8)

        itemCells
            .element(boundBy: 0)
            .coordinate(withNormalizedOffset: centerCenter)
            .press(
                forDuration: 0.1,
                thenDragTo: element.coordinate(
                    withNormalizedOffset: centerCenter
                )
            )
    }

    @discardableResult
    func wait(
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        _ = collectionView.wait(timeout: timeout, file: file, line: line)
        return self
    }

    @discardableResult
    func verify() -> Self {
        collectionView.verify()
        return self
    }
}
