import Foundation
import Sync

/// Generic type to validate a subscription purchase or redeem
public protocol ReceiptService {
    func send()
}

public enum ReceiptError: Error {
    case noData
}

/// Concrete implementation that sends the App Store Receipt to the backend
struct AppStoreReceiptService: ReceiptService {
    func send() {
        do {
            let data = try getReceipt()
            let receiptString = data.base64EncodedString(options: [])
        } catch {
            Log.capture(error: error)
        }
    }
}

// MARK: private methods
extension AppStoreReceiptService {
    func getReceipt() throws -> Data {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            throw ReceiptError.noData
        }
        return try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
    }
}
