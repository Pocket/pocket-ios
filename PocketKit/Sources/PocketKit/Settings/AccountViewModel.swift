import Analytics
import Combine
import SharedPocketKit
import SwiftUI
import Sync
import Textile

class AccountViewModel: ObservableObject {
    static let ToggleAppBadgeKey = "AccountViewModel.ToggleAppBadge"
    private let appSession: AppSession
    private let user: User
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let premiumUpgradeViewModelFactory: () -> PremiumUpgradeViewModel

    @Published var isPresentingHelp = false
    @Published var isPresentingTerms = false
    @Published var isPresentingPrivacy = false
    @Published var isPresentingSignOutConfirm = false
    @Published var isPresentingPremiumUpgrade = false
    @Published var isPresentingLicenses = false
    @Published var isPresentingAccountManagement = false
    @Published var isPresentingDeleteYourAccount = false
    @Published var isPresentingCancelationHelp = false

    @AppStorage("Settings.ToggleAppBadge")
    public var appBadgeToggle: Bool = false

    private var userStatusListener: AnyCancellable?

    @Published var isPremium: Bool

    init(appSession: AppSession,
         user: User,
         userDefaults: UserDefaults,
         notificationCenter: NotificationCenter,
         premiumUpgradeViewModelFactory: @escaping () -> PremiumUpgradeViewModel) {
        self.appSession = appSession
        self.user = user
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory
        self.isPremium = user.status == .premium

        userStatusListener = user
            .statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPremium = status == .premium
            }
    }

    func deleteAccount() {
    }

    func signOut() {
        // Post that we logged out to the rest of the app using the old session
        NotificationCenter.default.post(name: .userLoggedOut, object: appSession.currentSession)
        user.clear()
        appSession.currentSession = nil
    }

    func toggleAppBadge() {
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) {
            (granted, error) in
            guard error == nil && granted == true else {
                self.userDefaults.set(false, forKey: AccountViewModel.ToggleAppBadgeKey)
                DispatchQueue.main.async { [weak self] in
                    self?.appBadgeToggle = false
                }
                return
            }

            let currentValue = self.userDefaults.bool(forKey: AccountViewModel.ToggleAppBadgeKey)
            self.userDefaults.setValue(!currentValue, forKey: AccountViewModel.ToggleAppBadgeKey)
            self.notificationCenter.post(name: .listUpdated, object: nil)
        }
    }
}

// MARK: Premium upgrades
extension AccountViewModel {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        premiumUpgradeViewModelFactory()
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }
}
