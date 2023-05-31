// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import XCTest

@testable import PocketKit

class PremiumStatusViewModelTests: XCTestCase {
    var service: MockSubscriptionInfoService!

    override func setUp() {
        super.setUp()
        service = MockSubscriptionInfoService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }
    @MainActor
    func test_getInfoCalled() async {
        // Given
        let viewModel = PremiumStatusViewModel(service: service, tracker: MockTracker())
        service.callGetInfoExpectation = expectation(description: "getInfo() was called")
        // When
        await viewModel.getInfo()
        // Then
        waitForExpectations(timeout: 2) {error in
            guard let error else { return }
            XCTFail("Expectations not fulfilled: \(String(describing: error))")
        }
    }

    @MainActor
    func test_infoReceived() async {
        // Given
        let viewModel = PremiumStatusViewModel(service: service, tracker: MockTracker())
        XCTAssertTrue(viewModel.subscriptionInfoList.isEmpty)
        // When
        await viewModel.getInfo()
        // Then
        XCTAssertTrue(!viewModel.subscriptionInfoList.isEmpty)
        XCTAssertEqual(viewModel.subscriptionInfoList.count, 5)
        XCTAssertEqual(viewModel.subscriptionProvider, SubscriptionInfo.SubscriptionProvider.apple)
        XCTAssertEqual(viewModel.subscriptionInfoList[0].text, "Monthly")
        XCTAssertEqual(viewModel.subscriptionInfoList[1].text, "02/23/23")
        XCTAssertEqual(viewModel.subscriptionInfoList[2].text, "02/23/33")
        XCTAssertEqual(viewModel.subscriptionInfoList[3].text, "Apple")
        XCTAssertEqual(viewModel.subscriptionInfoList[4].text, "$0")
    }

    @MainActor
    func test_errorThrown() async {
        // Given
        service.shouldThrowError = true
        let viewModel = PremiumStatusViewModel(service: service, tracker: MockTracker())
        // When
        await viewModel.getInfo()
        // Then
        XCTAssertTrue(viewModel.isPresentingErrorAlert)
    }
}
