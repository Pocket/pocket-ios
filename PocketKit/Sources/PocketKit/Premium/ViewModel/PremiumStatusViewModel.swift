import Combine
import Foundation
import SharedPocketKit
import Sync

@MainActor
class PremiumSettingsViewModel: ObservableObject {
    @Published private(set) var subscription = ""
    @Published private(set) var datePurchased = ""
    @Published private(set) var renewalDate = ""
    @Published private(set) var purchaseLocation = ""
    @Published private(set) var price = ""

    @Published var isPresentingFAQ = false
    @Published var isContactingSupport = false
    @Published var isNoMailSupport = false

    let v3Client = Services.shared.v3Client

    func requestStatus() async {
        do {
            let result = try await v3Client.premiumStatus()
            subscription = result.subscriptionInfo.subscriptionType
            datePurchased = getDisplayedDate(datetime: result.subscriptionInfo.purchaseDate)
            renewalDate = getDisplayedDate(datetime: result.subscriptionInfo.renewDate)
            purchaseLocation = result.subscriptionInfo.source.capitalized
            price = result.subscriptionInfo.displayAmount
        } catch {
            Log.breadcrumb(category: "premium_status", level: .error, message: "v3 premium status error: \(error)")
        }
    }

    func getDisplayedDate(datetime: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yy"

        if let date = dateFormatterGet.date(from: datetime) {
            return dateFormatterPrint.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
}
