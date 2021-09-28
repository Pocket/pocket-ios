import XCTest


struct SlateDetailElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var cells: XCUIElementQuery {
        element.cells
    }

    func recommendationCell(_ title: String) -> XCUIElement {
        return element.cells
            .containing(.staticText, identifier: title)
            .element(boundBy: 0)
    }
}
