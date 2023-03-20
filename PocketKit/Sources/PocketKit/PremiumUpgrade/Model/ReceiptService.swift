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
#if DEBUG
        // TODO: at the moment we are not sending the receipt in debug
        print(transactionInfo)
#else
        try await client.sendAppstoreReceipt(
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
        /// replicates exactly the encoding in the legacy app. It's probably safe to replace with
        /// `.addingPercentEncoding(withAllowedCharacters: .alphanumerics)`,
        /// as this would always ensure `.utf8`, and we `CFURLCreateStringByAddingPercentEscapes` is deprecated since iOS 9.0.
        /// At most it would result with a few more percent-encoded (non alpha) characters, which should still be decoded correctly.
        guard let legacyReceipt = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            receiptString as CFString,
            nil,
            "!*'();:@&=+$,/?%#[]" as CFString,
            CFStringBuiltInEncodings.UTF8.rawValue
        ) else {
            throw ReceiptError.invalidReceipt
        }
        return legacyReceipt as String
    }
}
