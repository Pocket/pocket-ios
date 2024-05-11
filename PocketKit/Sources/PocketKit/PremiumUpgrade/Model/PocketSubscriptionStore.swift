// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SharedPocketKit
import StoreKit
import Sync

/// A concrete implementation of SubscriptionStore that handles premium subscriptions purchases from the App Store
@MainActor
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

    private var sessionSubscriptions = Set<AnyCancellable>()

    private let subscriptionMap: [String: PremiumSubscriptionType]

    init(user: User, receiptService: ReceiptService, subscriptionMap: [String: PremiumSubscriptionType]? = nil) {
        self.user = user
        self.receiptService = receiptService
        self.subscriptionMap = subscriptionMap ?? [Keys.shared.pocketPremiumMonthly: .monthly, Keys.shared.pocketPremiumAnnual: .annual]
        makeUserSessionListener()
    }

    deinit {
        Task {
            await stop()
        }
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
            Log.capture(message: "Failed to purchase a subscription: \(error)")
        }
    }

    /// Manually restore a purchase in those (rare?) cases when the automatic sync fails
    func restoreSubscription() async throws {
        try await AppStore.sync()
        await fetchActiveSubscription()
    }

    /// Start the transaction listener, fetch purchaseable subscriptions,
    /// and look for purchased subscriptions on the App Store
    func start() {
        transactionListener = makeTransactionListener()

        Task {
            do {
                // Obtain purchaseable subscriptions from the App Store
                try await requestSubscriptions()
            } catch {
                state = .failed
                Log.capture(message: "Failed to fetch purchaseable subscriptions from the App Store: \(error)")
            }
            // Restore a purchased subscription, if any
            await self.fetchActiveSubscription()
        }
    }
}

// MARK: private methods
private extension PocketSubscriptionStore {
    /// Reset user status and cancel the transaction listener
    func stop() {
        state = .unsubscribed
        transactionListener?.cancel()
    }
    /// Return a detached Task to lListen for transaction updates from the App Store
    /// that don't directly come from purchases on the active device.
    func makeTransactionListener() -> Task<Void, Error> {
        return Task.detached {
            for await transaction in Transaction.updates {
                do {
                    try await self.processTransaction(transaction)
                } catch {
                    Log.capture(message: "Transaction listener received an error while processing an incoming transaction: \(error)")
                }
            }
        }
    }

    /// Listen for user session, call start at login, stop at logout.
    func makeUserSessionListener() {
        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] _ in
            self?.start()
        }.store(in: &sessionSubscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] _ in
            self?.stop()
        }.store(in: &sessionSubscriptions)
    }

    /// Varify the passed transaction
    /// - Parameter transaction: a new transaction to verify
    /// - Returns: a verified trnasaction, if verification is successful. Throws an error otherwise.
    func verify(_ transaction: VerificationResult<Transaction>) throws -> Transaction {
        switch transaction {
        case .unverified:
            Log.capture(message: "Transaction verification failed: App Store returned an unverified transaction")
            throw SubscriptionStoreError.unverifiedPurchase
        case .verified(let verifiedTransaction):
            return verifiedTransaction
        }
    }

    /// Process the purchase of a product
    /// - Parameter product: the product to purchase
    func purchase(product: Product) async throws {
        // In the future, we could add `appAccountToken` in the purchase options.
        // It would need to be a UUID and should also be synced with the backend.
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
    func processTransaction(_ result: VerificationResult<Transaction>) async throws {
        let verifiedTransaction = try verify(result)
        await updateSubscriptionStatus(verifiedTransaction)
    }

    /// Looks for an active subscription
    func fetchActiveSubscription() async {
        for await transaction in Transaction.currentEntitlements {
            do {
                try await processTransaction(transaction)
                return
            } catch {
                Log.capture(message: "Unable to verify the transaction associated to a current entitlement. Error: \(error)")
            }
        }
    }

    /// Process a verified transaction and update app status if necessary
    func updateSubscriptionStatus(_ verifiedTransaction: Transaction) async {
        guard let expirationDate = verifiedTransaction.expirationDate, expirationDate > Date() else {
            await verifiedTransaction.finish()
            // if the subscription is expired, revert to free
            state = .unsubscribed
            user.setPremiumStatus(false)
            Log.debug("Subscription was expired")
            return
        }

        switch verifiedTransaction.productType {
        case .autoRenewable:
            if let subscription = subscriptions.first(where: { $0.product.id == verifiedTransaction.productID }) {
                state = .subscribed(subscription.type)
                user.setPremiumStatus(true)
                // send the App Store receipt to the backend with the current subscription
                do {
                    try await receiptService.send(subscription.product)
                } catch {
                    Log.capture(message: "Error while sending a receipt for a verified subscription: \(error)")
                }
            }
        default:
            // We do not have other product types as of now.
            Log.capture(message: "Received invalid product type")
        }
        await verifiedTransaction.finish()
    }
}
