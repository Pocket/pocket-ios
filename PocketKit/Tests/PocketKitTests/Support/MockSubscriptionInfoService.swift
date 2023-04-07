// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import PocketKit
import Sync
import XCTest

enum MockSubscriptionInfoServiceError: Error {
    case forcedError
}

class MockSubscriptionInfoService: SubscriptionInfoService {
    @Published var info: SubscriptionInfo = .emptyInfo
    var infoPublisher: Published<Sync.SubscriptionInfo>.Publisher { $info }

    var callGetInfoExpectation: XCTestExpectation?

    var shouldThrowError = false

    func getInfo() async throws {
        callGetInfoExpectation?.fulfill()
        if shouldThrowError {
            throw MockSubscriptionInfoServiceError.forcedError
        } else {
            let info = try decodeInfo()
            self.info = info
        }
    }

    private func decodeInfo() throws -> SubscriptionInfo {
        try JSONDecoder().decode(SubscriptionInfo.self, from: Self.mockInfo.data(using: .utf8)!)
    }

    private static let mockInfo =
    """
    {
        "source": "apple",
        "purchase_date": "2023-02-23 17:02:59",
        "renew_date": "2033-02-23 17:02:59",
        "subscription_type": "Monthly",
        "display_amount": "$0"
    }
    """
}
