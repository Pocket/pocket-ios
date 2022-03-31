import XCTest
@testable import SaveToPocketKit


class LoggedOutViewModelTests: XCTestCase {
    private var dismissTimer: Timer.TimerPublisher!

    private func subject(
        dismissTimer: Timer.TimerPublisher? = nil
    ) -> LoggedOutViewModel {
        LoggedOutViewModel(
            dismissTimer: dismissTimer ?? self.dismissTimer
        )
    }

    override func setUp() {
        self.continueAfterFailure = false

        dismissTimer = Timer.TimerPublisher(interval: 0, runLoop: .main, mode: .default)
    }
}

// MARK: - No session
extension LoggedOutViewModelTests {
    func test_viewWillAppear_automaticallyCompletesRequest() async {
        let context = MockExtensionContext(extensionItems: [])
        let viewModel = subject()

        let completeRequestExpectation = expectation(description: "expected completeRequest to be called")
        context.stubCompleteRequest { _, _ in
            completeRequestExpectation.fulfill()
        }

        viewModel.viewDidAppear(context: context)

        wait(for: [completeRequestExpectation], timeout: 1)
    }
}
