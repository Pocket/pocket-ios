// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct SlateDetailElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var cells: XCUIElementQuery {
        element.cells
    }

    var overscrollView: XCUIElement {
        element.otherElements["slate-detail-overscroll"]
    }

    func heroRecommendationCard(_ tilte: String) -> XCUIElement {
        element.staticTexts.element(matching: NSPredicate(format: "label = %@", tilte))
    }

    func carouselRecommendationCard(_ title: String) -> XCUIElement {
        element.scrollViews.staticTexts.matching(identifier: "home-carousel-item").element(matching: NSPredicate(format: "label = %@", title))
    }

    func saveButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - save")
        return element.buttons.element(matching: predicate)
    }

    func savedButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - saved")
        return element.buttons.element(matching: predicate)
    }

    func recommendationCell(_ title: String) -> RecommendationCellElement {
        let element = element.cells
            .containing(.staticText, identifier: title)
            .element(boundBy: 0)

        return RecommendationCellElement(element)
    }

    func overscroll() {
        let origin = CGVector(dx: 0.5, dy: 0.8)
        let destination = CGVector(dx: 0.5, dy: 0.2)

        element
            .coordinate(withNormalizedOffset: origin)
            .press(
                forDuration: 0.1,
                thenDragTo: element.coordinate(withNormalizedOffset: destination),
                withVelocity: .fast,
                thenHoldForDuration: 0
            )

        element
            .coordinate(withNormalizedOffset: origin)
            .press(
                forDuration: 0.1,
                thenDragTo: element.coordinate(withNormalizedOffset: destination),
                withVelocity: .fast,
                thenHoldForDuration: 1
            )
    }
}
