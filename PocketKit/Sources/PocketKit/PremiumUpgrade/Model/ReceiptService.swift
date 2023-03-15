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
    func send(_ product: Product?) async throws {
    #if DEBUG
        // TODO: at the moment we are not sending the receipt in debug
    #else
        let transactionInfo = try getReceipt()
        let source = "itunes"
        let productId = product?.id ?? ""
        let amount = product?.price != nil ? "\(product!.price)" : ""
        let transactionType = product != nil ? "purchase" : "restore"
        let currency = product?.priceFormatStyle.currencyCode ?? ""

        try await Services.shared.v3Client.sendAppstoreReceipt(
            source: source,
            transactionInfo: transactionInfo,
            amount: amount,
            productId: productId,
            currency: currency,
            transactionType: transactionType
        )
        #endif
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

        guard let receipt = receiptString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ReceiptError.invalidReceipt
        }
        return receipt
    }
}
