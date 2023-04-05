import XCTest

struct ReportViewElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var brokenMetaButton: XCUIElement {
        element.buttons["broken-meta"].wait()
    }

    var wrongCategoryButton: XCUIElement {
        element.buttons["wrong-category"].wait()
    }

    var sexuallyExplicitButton: XCUIElement {
        element.buttons["sexually-explicit"].wait()
    }

    var offensiveButton: XCUIElement {
        element.buttons["offensive"].wait()
    }

    var misinformationButton: XCUIElement {
        element.buttons["misinformation"].wait()
    }

    var otherButton: XCUIElement {
        element.buttons["other"].wait()
    }

    var commentEntry: XCUIElement {
        element.textViews["report-comment"].wait()
    }

    var submitButton: XCUIElement {
        element.buttons["submit-report"].wait()
    }
}
