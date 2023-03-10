import Combine
import Foundation
import SharedPocketKit
import Sync

@MainActor
class PremiumSettingsViewModel: ObservableObject {
    @Published private(set) var subscription = ""
    @Published private(set) var datePurchased = ""
    @Published private(set) var renewalDate = ""
    @Published private(set) var purchaseLocation = purchaseClient.Apple.rawValue
    @Published private(set) var price = "$"

    @Published var isPresentingFAQ = false
    @Published var isContactingSupport = false
    @Published var isNoMailSupport = false

    let v3Client = Services.shared.v3Client
    let session = Services.shared.appSession

    enum purchaseClient: String {
        case Apple
        case Google
        case Web
    }

    func requestStatus() async {
        do {
            let result = try await v3Client.premiumStatus(session: session.session!)
            print(result)
            subscription = result.subscriptionInfo.subscriptionType
            datePurchased = getDisplayedDate(datetime: result.subscriptionInfo.purchaseDate)
            renewalDate = getDisplayedDate(datetime: result.subscriptionInfo.renewDate)
            purchaseLocation = result.subscriptionInfo.source.capitalized
            price = result.subscriptionInfo.displayAmount
        } catch {
            print(error)
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
