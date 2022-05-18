import XCTest
@testable import SaveToPocketKit


class LoggedOutViewModelTests: XCTestCase {
    private func subject() -> LoggedOutViewModel {
        LoggedOutViewModel()
    }
}

// MARK: - No session
extension LoggedOutViewModelTests {
    func test_viewWillAppear_automaticallyCompletesRequest() async {
        let context = MockExtensionContext(extensionItems: [])
        let viewModel = subject()

        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")
        completeRequestExpectation.isInverted = true
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        viewModel.viewWillAppear(context: context, origin: self)

        wait(for: [completeRequestExpectation], timeout: 1)
    }
}
