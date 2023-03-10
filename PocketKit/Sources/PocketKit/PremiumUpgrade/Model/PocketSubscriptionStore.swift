// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import StoreKit
import Sync

/// A concrete implementation of SubscriptionStore that handles premium subscriptions purchases from the App Store
final class PocketSubscriptionStore: SubscriptionStore, ObservableObject {
    // Available subscriptions on the App Store
    @Published private(set) var subscriptions: [PremiumSubscription] = []
    var subscriptionsPublisher: Published<[PremiumSubscription]>.Publisher { $subscriptions }
    // Subscriber state
    @Published private(set) var state: PurchaseState = .unsubscribed
    var statePublisher: Published<PurchaseState>.Publisher { $state }

    private var user: User
    private let receiptService: ReceiptService
    /// Will listen for transaction updates while the app is running
    private var transactionListener: Task<Void, Error>?

    private let subscriptionMap: [String: PremiumSubscriptionType]

    init(user: User, receiptService: ReceiptService, subscriptionMap: [String: PremiumSubscriptionType]? = nil) {
        self.user = user
        self.receiptService = receiptService
        self.subscriptionMap = subscriptionMap ?? [Keys.shared.pocketPremiumMonthly: .monthly, Keys.shared.pocketPremiumAnnual: .annual]
        receiptService.send()
        transactionListener = makeTransactionListener()

        Task {
            do {
                // Pull available subscriptions from the App Store
                try await requestSubscriptions()
            } catch {
                state = .failed
                Log.capture(error: error)
            }
            // Restore a purchased subscription, if any
            await self.updateSubscription()
        }
        // TODO: Send the App Receipt to the backend
    }

    /// Fetch available subscriptions from the App Store
    func requestSubscriptions() async throws {
        subscriptions = try await .init(subscriptionMap: subscriptionMap)
    }

    /// Purchase a subscription
    /// - Parameter subscription: the `PremiumSubscription` to purchase
    func purchase(_ subscription: PremiumSubscription) async {
        do {
            try await purchase(product: subscription.product)
        } catch {
            print(error)
        }
    }

    /// Manually restore a purchase in those (rare?) cases when the automatic sync fails
    func restoreSubscription() async throws {
        try await AppStore.sync()
        // TODO: double check if we still need the following call when dealing with the real App Store
        await updateSubscription()
    }
}

// MARK: private methods
extension PocketSubscriptionStore {
    /// Return a detached Task to lListen for transaction updates from the App Store
    /// that don't directly come from purchases on the active device.
    private func makeTransactionListener() -> Task<Void, Error> {
        return Task.detached {
            for await transaction in Transaction.updates {
                do {
                    let verifiedTransaction = try self.verify(transaction)
                    await self.updateSubscription()
                    // Always finish a transaction, otherwise it will return.
                    await verifiedTransaction.finish()
                } catch {
                    // TODO: use logger here
                    print(error)
                }
            }
        }
    }

    /// Varify the passed transaction
    /// - Parameter transaction: a new transaction to verify
    /// - Returns: a verified trnasaction, if verification is successful. Throws an error otherwise.
    private func verify(_ transaction: VerificationResult<Transaction>) throws -> Transaction {
        switch transaction {
        case .unverified:
            throw SubscriptionStoreError.unverifiedPurchase
        case .verified(let verifiedTransaction):
            return verifiedTransaction
        }
    }

    /// Process the purchase of a product
    /// - Parameter product: the product to purchase
    private func purchase(product: Product) async throws {
        // TODO: we could add `appAccountToken` in the purchase options, but it needs an UUID
        let result = try await product.purchase()

        switch result {
        case .success(let transaction):
            let verifiedTransaction = try verify(transaction)
            await updateSubscription()
            // Always finish a transaction, otherwise it will return.
            await verifiedTransaction.finish()
        case .userCancelled:
            state = .cancelled
        case .pending:
            // TODO: check if we could have pending transactions for any reason
            break
        default:
            // future values might be available
            break
        }
    }

    /// Updates app status when a new subscription is found
    private func updateSubscription() async {
        // TODO: we need to handle the downgrade as well
        for await transaction in Transaction.currentEntitlements {
            do {
                let verifiedTransaction = try verify(transaction)
                switch verifiedTransaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.product.id == verifiedTransaction.productID }) {
                        state = .subscribed(subscription.type)
                        user.setPremiumStatus(true)
                        receiptService.send()
                    }
                default:
                    // We do not have other product types as of now.
                    Log.capture(message: "Received invalid product type")
                }
            } catch {
                // TODO: use logger here
                print(error)
            }
        }
    }
}
