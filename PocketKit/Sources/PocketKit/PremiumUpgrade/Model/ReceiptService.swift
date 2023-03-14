import Foundation
import StoreKit
import Sync

/// Generic type to send subscription receipt to a server
public protocol ReceiptService {
    func send(_ product: Product?) async throws
}

public enum ReceiptError: Error {
    case noData
}

/// Concrete implementation that sends the App Store Receipt to the Pocket backend
struct AppStoreReceiptService: ReceiptService {
    func send(_ product: Product?) async throws {
        let data = try getReceipt()
        let receiptString = data.base64EncodedString(options: [])
        let transactionInfo = receiptString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let source = "itunes"
        let productId = product?.id ?? ""
        let amount = product?.price != nil ? "\(product!.price)" : ""
        let transactionType = product != nil ? "purchase" : "restore"
        let currency = product?.priceFormatStyle.currencyCode ?? ""

        try await Services.shared.v3Client.sendAppstoreReceipt(
            source: source,
            transactionInfo: transactionInfo!,
            amount: amount,
            productId: productId,
            currency: currency,
            transactionType: transactionType
        )
    }
}

// MARK: private methods
extension AppStoreReceiptService {
    /// Return the App Store receipt if it exists
    func getReceipt() throws -> Data {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            throw ReceiptError.noData
        }
        return try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
    }
}
