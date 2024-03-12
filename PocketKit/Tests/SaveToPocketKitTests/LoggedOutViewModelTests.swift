// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

        await fulfillment(of: [completeRequestExpectation], timeout: 2)
    }
}
