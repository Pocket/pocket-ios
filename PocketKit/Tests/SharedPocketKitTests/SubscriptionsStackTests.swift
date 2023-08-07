// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import XCTest
@testable import SharedPocketKit

class SubscriptionTester {
    var updateReceivedExpectation: XCTestExpectation?
    @Published var subscriptionMessage = ""

    func updateMessage(_ message: String) {
        updateReceivedExpectation?.fulfill()
        subscriptionMessage = message
    }
}

class SubscriptionsStackTests: XCTestCase {
    var firstSet: Set<AnyCancellable>!
    var secondSet: Set<AnyCancellable>!

    func testPushSubscriptions() {
        var stack = SubscriptionsStack()

        let firstTester = SubscriptionTester()
        firstTester.updateReceivedExpectation = expectation(description: "first update received")

        firstSet = Set<AnyCancellable>()
        firstTester.$subscriptionMessage
            .dropFirst()
            .sink { message in
                XCTAssertEqual(message, "firstUpdate")
            }
            .store(in: &firstSet)

        stack.push(firstSet)
        firstSet = nil

        let secondTester = SubscriptionTester()
        secondTester.updateReceivedExpectation = expectation(description: "second update received")

        secondSet = Set<AnyCancellable>()
        secondTester.$subscriptionMessage
            .dropFirst()
            .sink { message in
                XCTAssertEqual(message, "secondUpdate")
            }
            .store(in: &secondSet)
        stack.push(secondSet)
        secondSet = nil

        firstTester.updateMessage("firstUpdate")
        secondTester.updateMessage("secondUpdate")

        wait(for: [firstTester.updateReceivedExpectation!, secondTester.updateReceivedExpectation!], timeout: 1)
    }

    func testPopSubscriptions() {
        var stack = SubscriptionsStack()
        var callCount = 0

        let firstTester = SubscriptionTester()

        firstSet = Set<AnyCancellable>()
        firstTester.$subscriptionMessage
            .dropFirst()
            .sink { message in
                callCount += 1
            }
            .store(in: &firstSet)

        stack.push(firstSet)
        firstSet = nil

        let secondTester = SubscriptionTester()

        secondSet = Set<AnyCancellable>()
        secondTester.$subscriptionMessage
            .dropFirst()
            .sink { message in
                callCount += 1
            }
            .store(in: &secondSet)
        stack.push(secondSet)
        secondSet = nil

        firstTester.updateMessage("whateverMessage")
        secondTester.updateMessage("whateverMessage")

        // two updates should be received, callCount should be equal to 2
        XCTAssertEqual(callCount, 2)
        stack.pop()

        firstTester.updateMessage("whateverMessage")
        secondTester.updateMessage("whateverMessage")

        // second set should be popped, thus, only 1 update should be received
        // callCount should be equal to 3
        XCTAssertEqual(callCount, 3)
        stack.pop()

        firstTester.updateMessage("whateverMessage")
        secondTester.updateMessage("whateverMessage")

        // no more updates should be received, callCount should be still equal to 3
        XCTAssertEqual(callCount, 3)
    }
}
