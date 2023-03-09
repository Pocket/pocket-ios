import Combine
import Foundation
import SharedPocketKit
import Sync

@MainActor
class PremiumSettingsViewModel: ObservableObject {
    @Published private(set) var subscription = "Monthly"
    @Published private(set) var datePurchased = "10/29/2021"
    @Published private(set) var renewalDate = "11/29/2021"
    @Published private(set) var purchaseLocation = purchaseClient.Apple.rawValue
    @Published private(set) var price = "$5.00"

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
        } catch {
            print(error)
        }
    }
}
