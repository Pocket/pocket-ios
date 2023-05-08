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
