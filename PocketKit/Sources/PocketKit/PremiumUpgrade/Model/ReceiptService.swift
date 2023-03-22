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
struct AppStoreReceiptService: ReceiptService {
    private let client: V3ClientProtocol

    init(client: V3ClientProtocol) {
        self.client = client
    }
    func send(_ product: Product?) async throws {
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
