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
    private let userManagementService: UserManagementServiceProtocol
    private let notificationCenter: NotificationCenter
    private let restoreSubscription: () async throws -> Void
    // Factories
    typealias PremiumUpgradeViewModelFactory = (Tracker, PremiumUpgradeSource) -> PremiumUpgradeViewModel
    private let premiumUpgradeViewModelFactory: PremiumUpgradeViewModelFactory
    typealias PremiumStatusViewModelFactory = (Tracker) -> PremiumSettingsViewModel
    private let premiumStatusViewModelFactory: PremiumStatusViewModelFactory
    // Presented sheets
    // TODO: we might want to add a coordinator of some sort here
    @Published var isPresentingHelp = false
    @Published var isPresentingTerms = false
    @Published var isPresentingPrivacy = false
    @Published var isPresentingSignOutConfirm = false
    @Published var isPresentingPremiumUpgrade = false
    @Published var isPresentingLicenses = false
    @Published var isPresentingAccountManagement = false
    @Published var isPresentingDeleteYourAccount = false
    @Published var isPresentingCancelationHelp = false
    @Published var isPresentingRestoreSuccessful = false
    @Published var isPresentingRestoreNotSuccessful = false
    @Published var isPresentingPremiumStatus = false

    @AppStorage("Settings.ToggleAppBadge")
    public var appBadgeToggle: Bool = false

    private var userStatusListener: AnyCancellable?

    @Published var isPremium: Bool

    init(appSession: AppSession,
         user: User,
         tracker: Tracker,
         userDefaults: UserDefaults,
         userManagementService: UserManagementServiceProtocol,
         notificationCenter: NotificationCenter,
         restoreSubscription: @escaping () async throws -> Void,
         premiumUpgradeViewModelFactory: @escaping PremiumUpgradeViewModelFactory,
         premiumStatusViewModelFactory: @escaping PremiumStatusViewModelFactory) {
        self.user = user
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.userManagementService = userManagementService
        self.notificationCenter = notificationCenter
        self.restoreSubscription = restoreSubscription
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory
        self.premiumStatusViewModelFactory = premiumStatusViewModelFactory
        self.isPremium = user.status == .premium

        userStatusListener = user
            .statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPremium = status == .premium
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

// MARK: premium upgrades factory
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

// MARK: premium statis fsctory
extension AccountViewModel {
    @MainActor
    func makePremiumStatusViewModel() -> PremiumSettingsViewModel {
        premiumStatusViewModelFactory(tracker)
    }

    /// Show Premium Status on tap
    func showPremiumStatus() {
        self.isPresentingPremiumStatus = true
    }
}

// MARK: Restore Subscription
extension AccountViewModel {
    @MainActor
    func attemptRestoreSubscription() {
        Task {
            do {
                try await self.restoreSubscription()
                isPresentingRestoreSuccessful = true
            } catch {
                isPresentingRestoreNotSuccessful = true
            }
        }
    }
}

// MARK: delete account factory
extension AccountViewModel {
    @MainActor
    func makeDeleteAccountViewModel() -> DeleteAccountViewModel {
        DeleteAccountViewModel(isPremium: self.isPremium, userManagementService: userManagementService, tracker: tracker)
    }
}

// MARK: Analytics
extension AccountViewModel {
    /// track premium upgrade view dismissed
    func trackPremiumDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button, .closeButton:
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
        tracker.track(event: Events.Settings.settingsImpression())
    }

    /// track logout row tapped
    func trackLogoutRowTapped() {
        tracker.track(event: Events.Settings.logoutRowTapped())
    }

    /// track logout confirm tapped
    func trackLogoutConfirmTapped() {
        tracker.track(event: Events.Settings.logoutConfirmTapped())
    }

    /// track account management viewed
    func trackAccountManagementImpression() {
        tracker.track(event: Events.Settings.accountManagementImpression())
    }

    /// track account management viewed
    func trackAccountManagementTapped() {
        tracker.track(event: Events.Settings.accountManagementRowTapped())
    }
    /// track delete settings row tapped
    func trackDeleteTapped() {
        tracker.track(event: Events.Settings.deleteRowTapped())
    }
}
