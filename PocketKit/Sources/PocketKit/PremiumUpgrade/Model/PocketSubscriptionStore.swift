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

        transactionListener = makeTransactionListener()

        Task {
            do {
                // Obtain purchaseable subscriptions from the App Store
                try await requestSubscriptions()
            } catch {
                state = .failed
                Log.capture(error: error)
            }
            // Restore a purchased subscription, if any
            await self.fetchActiveSubscription()

            do {
                // send App Store receipt at launch
                try await receiptService.send(nil)
            } catch {
                Log.capture(error: error)
            }
        }
    }

    deinit {
        transactionListener?.cancel()
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
            Log.capture(error: error)
        }
    }

    /// Manually restore a purchase in those (rare?) cases when the automatic sync fails
    func restoreSubscription() async throws {
        try await AppStore.sync()
        await fetchActiveSubscription()
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
                    try await self.processTransaction(transaction)
                } catch {
                    Log.capture(error: error)
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
            try await processTransaction(transaction)
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

    /// Process a received `StoreKit` varification result and, if it contains a vaild transaction,
    /// it verifies it and updates the app status accordingly
    private func processTransaction(_ result: VerificationResult<Transaction>) async throws {
        let verifiedTransaction = try verify(result)
        await updateSubscriptionStatus(verifiedTransaction)
    }

    /// Looks for an active subscription
    private func fetchActiveSubscription() async {
        for await transaction in Transaction.currentEntitlements {
            do {
                try await processTransaction(transaction)
            } catch {
                Log.capture(error: error)
            }
        }
    }

    /// Process a verified transaction and update app status if necessary
    private func updateSubscriptionStatus(_ verifiedTransaction: Transaction) async {
        guard let expirationDate = verifiedTransaction.expirationDate, expirationDate > Date() else {
            await verifiedTransaction.finish()
            Log.capture(message: "Subscription was expired")
            return
        }

        switch verifiedTransaction.productType {
        case .autoRenewable:
            if let subscription = subscriptions.first(where: { $0.product.id == verifiedTransaction.productID }) {
                state = .subscribed(subscription.type)
                user.setPremiumStatus(true)
                do {
                    try await receiptService.send(subscription.product)
                } catch {
                    Log.capture(error: error)
                }
            }
        default:
            // We do not have other product types as of now.
            Log.capture(message: "Received invalid product type")
        }
        await verifiedTransaction.finish()
    }
}
