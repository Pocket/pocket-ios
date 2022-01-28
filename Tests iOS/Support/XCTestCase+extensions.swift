import XCTest

extension XCTestCase {
    func waitForDisappearance(of element: XCUIElement) {
        let doesNotExist = NSPredicate(format: "exists == 0")
        let elementToNotExist = expectation(for: doesNotExist, evaluatedWith: element)
        wait(for: [elementToNotExist], timeout: 3)
    }

    func waitForDisappearance(of element: PocketUIElement) {
        waitForDisappearance(of: element.element)
    }
}
