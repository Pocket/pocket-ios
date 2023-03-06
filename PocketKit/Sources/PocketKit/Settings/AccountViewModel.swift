import Analytics
import Combine
import SharedPocketKit
import SwiftUI
import Sync
import Textile

class AccountViewModel: ObservableObject {
    static let ToggleAppBadgeKey = "AccountViewModel.ToggleAppBadge"
    private let user: User
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let premiumUpgradeViewModelFactory: (Tracker, PremiumUpgradeSource) -> PremiumUpgradeViewModel
    private let userManagementService: UserManagementServiceProtocol

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

    /// Signals to the DeleteAccountView that there was an error deleting the account
    @Published var hasError: Bool = false

    /// Signals to the DeleteAccount View that the account is being deleted.
    @Published var isDeletingAccount: Bool = false

    init(appSession: AppSession,
         user: User,
         tracker: Tracker,
         userDefaults: UserDefaults,
         userManagementService: UserManagementServiceProtocol,
         notificationCenter: NotificationCenter,
         premiumUpgradeViewModelFactory: @escaping (Tracker, PremiumUpgradeSource) -> PremiumUpgradeViewModel) {
        self.user = user
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.userManagementService = userManagementService
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory
        self.isPremium = user.status == .premium

        userStatusListener = user
            .statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPremium = status == .premium
            }
    }

    /// Calls the user management service to delete the account and log the user out.
    func deleteAccount() {
        self.isDeletingAccount = true
        Task {
            do {
                try await userManagementService.deleteAccount()
            } catch {
                Log.capture(error: error)
                self.hasError = true
            }
            self.isDeletingAccount = false
        }
    }

    /// Calls the user management service to sign the user out.
    func signOut() {
        userManagementService.logout()
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
        premiumUpgradeViewModelFactory(tracker, .settings)
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }
}

// MARK: Analytics
extension AccountViewModel {
    /// track premium upgrade view dismissed
    func trackPremiumDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button:
            tracker.track(event: Events.Premium.premiumUpgradeViewDismissed(reason: dismissReason))
        case .system:
            break
        }
    }
    /// track premium upsell viewed
    func trackPremiumUpsellViewed() {
        tracker.track(event: Events.Settings.premiumUpsellViewed())
    }

    /// track settings screen was viewed
    func trackSettingsViewed() {
        tracker.track(event: Events.Settings.SettingsView())
    }
}
