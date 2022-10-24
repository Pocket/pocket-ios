import XCTest

extension XCTestCase {
    func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 3) {
        let doesNotExist = NSPredicate(format: "exists == 0")
        let elementToNotExist = expectation(for: doesNotExist, evaluatedWith: element)
        wait(for: [elementToNotExist], timeout: timeout)
    }

    func waitForDisappearance(of element: PocketUIElement) {
        waitForDisappearance(of: element.element)
    }

    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: 3)
    }
}
