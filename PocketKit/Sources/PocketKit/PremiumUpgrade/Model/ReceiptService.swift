import Foundation
import StoreKit
import Sync

/// Generic type to send subscription receipt to a server
public protocol ReceiptService {
    func send(_ product: Product?) async throws
}

public enum ReceiptError: Error {
    case noData
    case invalidReceipt
}

/// Concrete implementation that sends the App Store Receipt to the Pocket backend
class AppStoreReceiptService: NSObject, ReceiptService {
    private let client: V3ClientProtocol

    private let receiptRequest: SKReceiptRefreshRequest

    private var storeKit1Continuation: CheckedContinuation<SKRequest, Error>?

    init(client: V3ClientProtocol) {
        self.client = client
        self.receiptRequest = SKReceiptRefreshRequest()
        super.init()
    }

    func send(_ product: Product?) async throws {
        // First make sure a receipt even exists before we try and get one.
        _ = try getReceipt()

        // Ensure we have a receipt to work with from StoreKit 1
        var _: SKRequest = try await withCheckedThrowingContinuation { continuation in
            storeKit1Continuation = continuation
            self.receiptRequest.delegate = self
            self.receiptRequest.start()
        }

        let transactionInfo = try getReceipt()
        let source = "itunes"
        let productId = product?.id ?? ""
        let amount = product?.price != nil ? "\(product!.price)" : ""
        let transactionType = product != nil ? "purchase" : "restore"
        let currency = product?.priceFormatStyle.currencyCode ?? ""

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
        storeKit1Continuation?.resume(returning: request)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        storeKit1Continuation?.resume(throwing: error)
    }
}

// MARK: private methods
private extension AppStoreReceiptService {
    /// Return the App Store receipt if it exists
    func getReceipt() throws -> String {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            throw ReceiptError.noData
        }
        let receiptString = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            .base64EncodedString(options: [])
        return receiptString
    }
}
