// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct SearchViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var recentSearchesView: XCUIElement {
        let query: XCUIElementQuery

        if #available(iOS 16, *) {
            query = element.collectionViews
        } else {
            query = element.tables
        }

        return query["recent-searches"]
    }

    var searchResultsView: XCUIElement {
        let query: XCUIElementQuery

        if #available(iOS 16, *) {
            query = element.collectionViews
        } else {
            query = element.tables
        }

        return query["search-results"]
    }

    var skeletonView: XCUIElement {
        let query: XCUIElementQuery

        if #available(iOS 16, *) {
            query = element.collectionViews
        } else {
            query = element.tables
        }

        return query["skeleton-view"]
    }

    func hasBanner(with message: String) -> Bool {
        element.staticTexts["banner"].wait().exists && element.staticTexts[message].wait().exists
    }

    func searchItemCell(matching identifier: String) -> ItemRowElement {
        ItemRowElement(searchResultsView.cells.containing(.staticText, identifier: identifier).element(boundBy: 0))
    }
}
