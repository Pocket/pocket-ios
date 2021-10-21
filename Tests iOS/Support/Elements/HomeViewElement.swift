// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct HomeViewElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var overscrollView: XCUIElement {
        element.otherElements["home-overscroll"]
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

    func recommendationCell(_ title: String) -> RecommendationCellElement {
        let element = element.cells
            .containing(.staticText, identifier: title)
            .element(boundBy: 0)

        return RecommendationCellElement(element)
    }

    func pullToRefresh() {
        let topCenter = CGVector(dx: 0.5, dy: 0.1)
        let centerCenter = CGVector(dx: 0.5, dy: 0.8)

        element.cells
            .element(boundBy: 0)
            .coordinate(withNormalizedOffset: topCenter)
            .press(
                forDuration: 0.1,
                thenDragTo: element.coordinate(
                    withNormalizedOffset: centerCenter
                )
            )
    }
    
    func overscroll() {
        let origin = CGVector(dx: 0.5, dy: 0.8)
        let destination = CGVector(dx: 0.5, dy: 0.2)

        element
            .coordinate(withNormalizedOffset: origin)
            .press(forDuration: 0.1, thenDragTo: element.coordinate(withNormalizedOffset: destination), withVelocity: .fast, thenHoldForDuration: 0)

        element
            .coordinate(withNormalizedOffset: origin)
            .press(forDuration: 0.1, thenDragTo: element.coordinate(withNormalizedOffset: destination), withVelocity: .fast, thenHoldForDuration: 0)

        element
            .coordinate(withNormalizedOffset: origin)
            .press(forDuration: 0.1, thenDragTo: element.coordinate(withNormalizedOffset: destination), withVelocity: .fast, thenHoldForDuration: 1)
    }
}
