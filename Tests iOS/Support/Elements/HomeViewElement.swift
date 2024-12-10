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

    var signinBanner: XCUIElement {
        element.cells.matching(identifier: "home-signinBanner").firstMatch
    }

    var signinContinueButton: XCUIElement {
        let predicate = NSPredicate(format: "label = %@", "Continue")
        return signinBanner.buttons.element(matching: predicate)
    }

    func savedItemCell(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title)
        return savedItemCells.element(matching: predicate)
    }

    func savedItemCell(at index: Int) -> XCUIElement {
        return savedItemCells.element(boundBy: index)
    }

    var savedItemCells: XCUIElementQuery {
        return element.scrollViews.staticTexts.matching(identifier: "home-carousel-item")
    }

    func recentSavesView(matching string: String) -> RecentSavesCellElement {
        return RecentSavesCellElement(element.otherElements["recent-saves"].staticTexts[string])
    }

    func recentSavesFavoriteButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - favorite")
        return element.otherElements["recent-saves"].buttons.element(matching: predicate)
    }

    func recentSavesFavoritedButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - favorited")
        return element.otherElements["recent-saves"].buttons.element(matching: predicate)
    }

    func recentSavesOverflowButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - overflow-menu")
        return element.otherElements["recent-saves"].buttons.element(matching: predicate)
    }

    func recentSavesOverflowArchiveButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - overflow-archive")
        return element.otherElements["recent-saves"].buttons.element(matching: predicate)
    }

    func recommendationsSaveButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - save")
        return element.otherElements["recommendations"].buttons.element(matching: predicate)
    }

    func recommendationsSavedButton(_ title: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", title + " - saved")
        return element.otherElements["recommendations"].buttons.element(matching: predicate)
    }

    func sectionHeader(_ title: String) -> SectionHeaderElement {
        let predicate = NSPredicate(format: "label = %@", title)
        let element = element.otherElements.containing(predicate).element(boundBy: 0)
        return SectionHeaderElement(element)
    }

    func topSeeAllButton() -> XCUIElement {
        element.buttons["See all"].firstMatch
    }

    func recommendationCell(_ title: String) -> RecommendationCellElement {
        let element = element.cells
            .containing(.staticText, identifier: title)
            .element(boundBy: 0)

        return RecommendationCellElement(element)
    }

    func heroRecommendationCard(_ tilte: String) -> XCUIElement {
        element.staticTexts.matching(identifier: "home-hero-item").element(matching: NSPredicate(format: "label = %@", tilte))
    }

    func carouselRecommendationCard(_ title: String) -> XCUIElement {
        element.scrollViews.staticTexts.matching(identifier: "home-carousel-item").element(matching: NSPredicate(format: "label = %@", title))
    }

    func carouselCardLabel(_ text: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", text)
        return element.scrollViews.staticTexts.containing(predicate).element
    }

    func pullToRefresh() {
        let firstCell = savedItemCell(at: 0).wait()
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 6))
        start.press(forDuration: 0, thenDragTo: finish)
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

    var overscrollText: XCUIElement {
        element.otherElements["slate-detail-overscroll"]
    }

    var seeAllCollectionButton: XCUIElement {
        element.staticTexts["See all"]
    }

    var returnToHomeButton: XCUIElement {
        element.buttons["Home"]
    }
}
