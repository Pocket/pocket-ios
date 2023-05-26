// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit

final class NotificationRelayTests: XCTestCase {
    func test_expected_bannerRequest_for_serverError() {
        let retainedRelayInstance = NotificationRelay(NotificationCenter.default)

        let handler: (Notification) -> Bool = { notification in
            return true
        }

        let expectation = expectation(forNotification: .bannerRequested, object: nil, handler: handler)

        NotificationCenter.default.post(name: .serverError, object: 429)

        wait(for: [expectation], timeout: 5)
    }

    func test_unanticipated_serverError() {
        let retainedRelayInstance = NotificationRelay(NotificationCenter.default)

        let handler: (Notification) -> Bool = { _ in
            return false
        }

        let expectation = expectation(forNotification: .bannerRequested, object: nil, handler: handler)
        expectation.isInverted = true

        NotificationCenter.default.post(name: .serverError, object: 499)

        wait(for: [expectation], timeout: 5)
    }

    func test_serverError_non_integer_object() {
        let retainedRelayInstance = NotificationRelay(NotificationCenter.default)

        let handler: (Notification) -> Bool = { _ in
            return false
        }

        let expectation = expectation(forNotification: .bannerRequested, object: nil, handler: handler)
        expectation.isInverted = true

        NotificationCenter.default.post(name: .serverError, object: "non-integer-object")

        wait(for: [expectation], timeout: 5)
    }
}
