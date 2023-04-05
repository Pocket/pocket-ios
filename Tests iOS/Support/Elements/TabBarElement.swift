import XCTest

struct TabBarElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var homeButton: XCUIElement {
        element.buttons["Home"].wait()
    }

    var savesButton: XCUIElement {
        element.buttons["Saves"].wait()
    }

    var accountButton: XCUIElement {
        element.buttons["Account"].wait()
    }

    var settingsButton: XCUIElement {
        element.buttons["Settings"].wait()
    }
}
