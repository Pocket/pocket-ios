// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import Combine
import Foundation
import SharedPocketKit
import Sync
import Localization

/// Factory to construct and inject `PremiumStatusViewModel` where needed
typealias PremiumStatusViewModelFactory = () -> PremiumStatusViewModel

@MainActor
class PremiumStatusViewModel: ObservableObject {
    private let service: SubscriptionInfoService
    private let tracker: Tracker

    @Published var subscriptionInfoList = [LabeledText]()
    @Published var subscriptionProvider: SubscriptionInfo.SubscriptionProvider = .unknown

    @Published var isPresentingFAQ = false
    @Published var isContactingSupport = false
    @Published var isNoMailSupport = false
    @Published var isPresentingErrorAlert = false

    private var cancellable: AnyCancellable?

    init(service: SubscriptionInfoService, tracker: Tracker) {
        self.service = service
        self.tracker = tracker
        cancellable = service
            .infoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subscriptionInfo in
                guard let self else { return }
                self.subscriptionInfoList = self.makeLabeledList(subscriptionInfo)
                self.subscriptionProvider = subscriptionInfo.subscriptionProvider
        }
    }

    func getInfo() async {
        do {
            try await service.getInfo()
        } catch {
            Log.capture(error: error)
            isPresentingErrorAlert = true
        }
    }

    /// Constructs a list of label + item from `SubscriptionInfo`
    /// - Parameter labels: the list of labels
    private func makeLabeledList(_ info: SubscriptionInfo) -> [LabeledText] {
        [LabeledText(title: Labels.subscriptionType, text: info.subscriptionType),
         LabeledText(title: Labels.dateOfPurchase, text: info.dateOfPurchase),
         LabeledText(title: Labels.dateOfRenewal, text: info.dateOfRenewal),
         LabeledText(title: Labels.providerName, text: info.providerName),
         LabeledText(title: Labels.displayAmount, text: info.displayAmount)]
    }

    private enum Labels {
        static let subscriptionType = Localization.Settings.Premium.Settings.subscription
        static let dateOfPurchase = Localization.Settings.Premium.Settings.datePurchased
        static let dateOfRenewal = Localization.Settings.Premium.Settings.renewalDate
        static let providerName = Localization.Settings.Premium.Settings.purchaseLocation
        static let displayAmount = Localization.Settings.Premium.Settings.price
    }
}

/// Formatted properties
extension SubscriptionInfo {
    /// Describes the provider of the subscription
    enum SubscriptionProvider: String {
        case apple
        case itunes
        case web
        case google
        case unknown

        var isApple: Bool {
            switch self {
            case .apple, .itunes:
                return true
            default:
                return false
            }
        }
    }

    var dateOfPurchase: String {
        formatDate(purchaseDate)
    }

    var dateOfRenewal: String {
        formatDate(renewDate)
    }

    var providerName: String {
        source.capitalized
    }

    var subscriptionProvider: SubscriptionProvider {
        SubscriptionProvider(rawValue: source) ?? .unknown
    }
}

/// Formatter
private extension SubscriptionInfo {
    func formatDate(_ datetime: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yy"

        if let date = dateFormatterGet.date(from: datetime) {
            return dateFormatterPrint.string(from: date)
        } else {
            return ""
        }
    }
}
