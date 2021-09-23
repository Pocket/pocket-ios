import XCTest


struct TabBarElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var homeButton: XCUIElement {
        element.buttons["Home"]
    }

    var myListButton: XCUIElement {
        element.buttons["My List"]
    }
}
