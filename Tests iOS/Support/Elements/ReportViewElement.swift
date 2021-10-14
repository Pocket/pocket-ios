import XCTest


struct ReportViewElement: PocketUIElement {
    let element: XCUIElement
    
    init(_ element: XCUIElement) {
        self.element = element
    }
    
    var brokenMetaButton: XCUIElement {
        element.buttons["broken-meta"]
    }
    
    var wrongCategoryButton: XCUIElement {
        element.buttons["wrong-category"]
    }
    
    var sexuallyExplicitButton: XCUIElement {
        element.buttons["sexually-explicit"]
    }
    
    var offensiveButton: XCUIElement {
        element.buttons["offensive"]
    }
    
    var misinformationButton: XCUIElement {
        element.buttons["misinformation"]
    }
    
    var otherButton: XCUIElement {
        element.buttons["other"]
    }
    
    var commentEntry: XCUIElement {
        element.textViews["report-comment"]
    }
    
    var submitButton: XCUIElement {
        element.buttons["submit-report"]
    }
}
