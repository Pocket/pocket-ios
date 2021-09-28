import XCTest


struct SlateDetailElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var cells: XCUIElementQuery {
        element.cells
    }
}
