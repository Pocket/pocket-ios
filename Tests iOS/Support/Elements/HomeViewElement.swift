// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct HomeViewElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    func topicChip(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title)
        return element.cells
            .matching(identifier: "topic-chip")
            .containing(predicate).element(boundBy: 0)
    }

    func slateHeader(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title)
        return element.otherElements.containing(predicate).element(boundBy: 0)
    }

    func recommendationCell(_ title: String) -> XCUIElement {
        return element.cells
            .containing(.staticText, identifier: title)
            .element(boundBy: 0)
    }
}
