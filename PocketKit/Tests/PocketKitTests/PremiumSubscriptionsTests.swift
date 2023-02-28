// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import StoreKitTest
@testable import PocketKit

final class PremiumSubscriptionsTests: XCTestCase {
    override func setUpWithError() throws {
        let bundle = Bundle.module
        let url = bundle.url(forResource: "StoreKit/mocksubscriptions", withExtension: "storekit")!
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
    }

    func test_premiumSubscriptions_retrieved() async throws {
        let store = PremiumSubscriptionStore(user: MockUser(), subscriptionMap: ["monthly.subscription.pocket": .monthly, "annual.subscription.pocket": .annual])
        try await store.requestSubscriptions()
        XCTAssertEqual(store.subscriptions.count, 2)
        XCTAssertTrue(store.subscriptions.contains { $0.product.id == "monthly.subscription.pocket" })
        XCTAssertTrue(store.subscriptions.contains { $0.product.id == "annual.subscription.pocket" })
    }

    func test_viewmodel_request_subscriptions_to_store() async throws {
        // Given
        let store = PremiumSubscriptionStore(user: MockUser(), subscriptionMap: ["monthly.subscription.pocket": .monthly, "annual.subscription.pocket": .annual])
        let viewModel = PremiumUpgradeViewModel(store: store)

        // When
        try await viewModel.requestSubscriptions()

        // Then
        XCTAssertEqual(store.subscriptions.count, 2)
        XCTAssertTrue(store.subscriptions.contains { $0.product.id == "monthly.subscription.pocket" })
        XCTAssertTrue(store.subscriptions.contains { $0.product.id == "annual.subscription.pocket" })
    }
}
