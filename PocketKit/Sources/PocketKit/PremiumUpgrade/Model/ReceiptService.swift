// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import StoreKit
import Sync
import SharedPocketKit

/// Generic type to send subscription receipt to a server
public protocol ReceiptService {
    func send(_ product: Product) async throws
}

public enum ReceiptError: LoggableError {
    case noData
    case invalidReceipt

    public var logDescription: String {
        switch self {
        case .noData: return "No data"
        case .invalidReceipt: return "Invalid receipt"
        }
    }
}

/// Concrete implementation that sends the App Store Receipt to the Pocket backend
class AppStoreReceiptService: NSObject, ReceiptService {
    private let client: V3ClientProtocol

    private let receiptRequest: SKReceiptRefreshRequest
    // using an array of continuations so that each one gets resumed and then removed
    private var storeKit1Continuations = [CheckedContinuation<SKRequest, Error>]()

    private let continuationQueue = DispatchQueue(label: "ContinuationQueue", qos: .background)

    init(client: V3ClientProtocol) {
        self.client = client
        self.receiptRequest = SKReceiptRefreshRequest()
        super.init()
    }

    func send(_ product: Product) async throws {
        // on simulators, we typically use a local test environment, and don't want
        // to send the receipt to the backend
        #if targetEnvironment(simulator)
        return
        #endif

        // Ensure we have a receipt to work with from StoreKit 1
        _ = try await withCheckedThrowingContinuation { [unowned self] continuation in
            storeKit1Continuations.append(continuation)
            self.receiptRequest.delegate = self
            self.receiptRequest.start()
        }

        let transactionInfo = try getReceipt()
        let source = "itunes"
        let productId = product.id
        let amount = "\(product.price)"
        let transactionType = "purchase"
        let currency = product.priceFormatStyle.currencyCode

        try await client.sendAppstoreReceipt(
            source: source,
            transactionInfo: transactionInfo,
            amount: amount,
            productId: productId,
            currency: currency,
            transactionType: transactionType
        )
    }
}

// MARK: StoreKit 1 delegate
extension AppStoreReceiptService: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        continuationQueue.async { [unowned self] in
            self.storeKit1Continuations.forEach { $0.resume(returning: request) }
            self.storeKit1Continuations.removeAll()
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        continuationQueue.async { [unowned self] in
            self.storeKit1Continuations.forEach { $0.resume(throwing: error) }
            self.storeKit1Continuations.removeAll()
            Log.capture(message: "StoreKit receipt request failed with error: \(error)")
        }
    }
}

// MARK: private methods
private extension AppStoreReceiptService {
    /// Return the App Store receipt if it exists
    func getReceipt() throws -> String {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            Log.capture(message: "Unable to find the StoreKit receipt on device")
            throw ReceiptError.noData
        }
        let receiptString = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            .base64EncodedString(options: [])
        return receiptString
    }
}
