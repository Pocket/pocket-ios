// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import StoreKit
import Sync

/// Subscription store error(s)
enum SubscriptionStoreError: Error {
    case unverifiedPurchase
}

/// A type that handles premium subscriptions purchases from the App Store
final class PremiumSubscriptionStore: ObservableObject {
    @Published private(set) var subscriptions: [PremiumSubscription] = []
    private var user: User
    /// Will listen for transaction updates while the app is running
    private var transactionListener: Task<Void, Error>?

    // TODO: determine what we actually need to store here
    /// For premium users, this property contains details of the purchased subscription
    @Published private(set) var purchasedSubscription: PremiumSubscription?

    init(user: User) {
        self.user = user
        transactionListener = makeTransactionListener()

        Task {
            do {
                try await requestSubscriptions()
            } catch {
                // TODO: use logger here
                print(error)
            }
        }
    }

    /// Fetch available subscriptions from the App Store
    func requestSubscriptions() async throws {
        subscriptions = try await .init()
    }

    /// Return a detached Task to lListen for transaction updates from the App Store
    /// that don't directly come from purchases on the active device.
    func makeTransactionListener() -> Task<Void, Error> {
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
    func verify(_ transaction: VerificationResult<Transaction>) throws -> Transaction {
        switch transaction {
        case .unverified:
            throw SubscriptionStoreError.unverifiedPurchase
        case .verified(let verifiedTransaction):
            return verifiedTransaction
        }
    }

    func purchase(_ subscription: PremiumSubscription) async {
        do {
            try await purchase(product: subscription.product)
        } catch {
            print(error)
        }
    }

    /// Process the purchase of a product
    /// - Parameter product: the product to purchase
    private func purchase(product: Product) async throws {
        // TODO: we might want to add `appAccountToken` in the options
        let result = try await product.purchase()

        switch result {
        case .success(let transaction):
            let verifiedTransaction = try verify(transaction)
            await updateSubscription()
            // Always finish a transaction, otherwise it will return.
            await verifiedTransaction.finish()
        default:
            // TODO: we might want to handle states differently, e. g. when user cancels.
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
                        purchasedSubscription = subscription
                        user.setPremiumStatus(true)
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
