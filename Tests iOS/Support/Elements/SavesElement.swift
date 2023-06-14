// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct SavesElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var selectionSwitcher: SelectionSwitcherElement {
        return SelectionSwitcherElement(element.otherElements["saves-selection-switcher"])
    }

    var tagsFilterView: TagsFilterViewElement {
        TagsFilterViewElement(element.otherElements["filter-tags"])
    }

    var searchView: SearchViewElement {
        SearchViewElement(element.otherElements["search-view"])
    }

    var addSavedItem: AddSavedItemElement {
        AddSavedItemElement(element)
    }

    private var collectionView: XCUIElement {
        element.otherElements["saves"].collectionViews.firstMatch
    }

    var itemCells: XCUIElementQuery {
        collectionView.cells.matching(NSPredicate(format: "identifier = %@", "saves-item"))
    }

    var skeletonCells: XCUIElementQuery {
        collectionView.cells.matching(NSPredicate(format: "identifier = %@", "saves-item-skeleton"))
    }

    func filterButton(for type: String) -> XCUIElement {
        collectionView.cells.matching(
            NSPredicate(
                format: "identifier = %@",
                "topic-chip"
            )
        ).containing(.staticText, identifier: type).element(boundBy: 0)
    }

    func addSavedItemButton() -> XCUIElement {
        element.buttons["add_saved_item_button"]
    }

    func selectedTagChip(for tag: String) -> XCUIElement {
        collectionView.cells.matching(
            NSPredicate(
                format: "identifier = %@",
                "selected-tag-chip"
            )
        ).containing(.staticText, identifier: tag).element(boundBy: 0)
    }

    func emptyStateView(for type: String) -> XCUIElement {
        element.otherElements[type]
    }

    func searchEmptyStateView(for type: String) -> XCUIElement {
        element.images[type]
    }

    var archiveSwipeButton: XCUIElement {
        collectionView.buttons["Archive"]
    }

    var moveToSavesSwipeButton: XCUIElement {
        collectionView.buttons["Move to Saves"]
    }

    var itemCount: Int {
        itemCells.count
    }

    var skeletonCellCount: Int {
        skeletonCells.count
    }

    func skeletonCell(at index: Int) -> XCUIElement {
        return skeletonCells.element(boundBy: index)
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
        let firstCell = itemCells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 6))
        start.press(forDuration: 0, thenDragTo: finish)
    }

    @discardableResult
    func wait(
        timeout: TimeInterval = 3,
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
