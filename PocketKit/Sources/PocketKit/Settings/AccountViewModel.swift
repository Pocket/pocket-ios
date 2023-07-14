// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import Combine
import SharedPocketKit
import SwiftUI
import StoreKit
import Sync
import Textile
import Network

class AccountViewModel: ObservableObject {
    static let ToggleAppBadgeKey = UserDefaults.Key.toggleAppBadge

    private let user: User
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let userManagementService: UserManagementServiceProtocol
    private let notificationCenter: NotificationCenter
    private let restoreSubscription: () async throws -> Void
    private let networkPathMonitor: NetworkPathMonitor
    private let featureFlags: FeatureFlagServiceProtocol

    // Factories
    private let premiumUpgradeViewModelFactory: PremiumUpgradeViewModelFactory
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
    @Published var isPresentingOfflineView = false
    @Published var isPresentingRestoreSuccessful = false
    @Published var isPresentingRestoreNotSuccessful = false
    @Published var isPresentingPremiumStatus = false
    @Published var isPresentingHooray = false
    @Published var isPresentingDebugMenu = false

    @AppStorage public var appBadgeToggle: Bool
    @AppStorage public var originalViewToggle: Bool

    private var userStatusListener: AnyCancellable?

    @Published var isPremium: Bool

    var isOffline: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    var userEmail: String {
        user.email
    }

    init(appSession: AppSession,
         user: User,
         tracker: Tracker,
         userDefaults: UserDefaults,
         userManagementService: UserManagementServiceProtocol,
         notificationCenter: NotificationCenter,
         networkPathMonitor: NetworkPathMonitor,
         restoreSubscription: @escaping () async throws -> Void,
         premiumUpgradeViewModelFactory: @escaping PremiumUpgradeViewModelFactory,
         premiumStatusViewModelFactory: @escaping PremiumStatusViewModelFactory,
         featureFlags: FeatureFlagServiceProtocol
    ) {
        self.user = user
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.userManagementService = userManagementService
        self.notificationCenter = notificationCenter
        self.restoreSubscription = restoreSubscription
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory
        self.premiumStatusViewModelFactory = premiumStatusViewModelFactory
        self.isPremium = user.status == .premium
        self.networkPathMonitor = networkPathMonitor
        self.featureFlags = featureFlags

        _appBadgeToggle = AppStorage(wrappedValue: false, UserDefaults.Key.toggleAppBadge, store: userDefaults)

        _originalViewToggle = AppStorage(wrappedValue: false, UserDefaults.Key.toggleOriginalView, store: userDefaults)

        userStatusListener = user
            .statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPremium = status == .premium
            }
    }

    /// Calls the user management service to sign the user out.
    func signOut() {
        Log.breadcrumb(category: "auth", level: .error, message: "User did log out")
        userManagementService.logout()
    }

    func toggleAppBadge(to isEnabled: Bool) {
        tracker.track(event: Events.Settings.appBadgeToggled(newValue: isEnabled))

        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { [weak self]
            (granted, error) in
            guard let self else { return }

            guard error == nil && granted == true else {
                if let error {
                    Log.capture(error: error)
                }

                tracker.track(event: Events.Settings.appBadgePermissionDenied())

                self.userDefaults.set(false, forKey: AccountViewModel.ToggleAppBadgeKey)
                DispatchQueue.main.async { [weak self] in
                    self?.appBadgeToggle = false
                }

                return
            }

            self.userDefaults.setValue(isEnabled, forKey: AccountViewModel.ToggleAppBadgeKey)
            self.notificationCenter.post(name: .listUpdated, object: nil)
        }
    }

    func toggleOriginalView(to isEnabled: Bool) {
        tracker.track(event: Events.Settings.originalViewToggled(newValue: isEnabled))
        self.userDefaults.setValue(isEnabled, forKey: UserDefaults.Key.toggleOriginalView)
    }

    var showDebugMenu: Bool {
        featureFlags.isAssigned(flag: .debugMenu)
    }
}

// MARK: premium upgrades factory
extension AccountViewModel {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        premiumUpgradeViewModelFactory(.settings)
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }
}

// MARK: premium statis fsctory
extension AccountViewModel {
    @MainActor
    func makePremiumStatusViewModel() -> PremiumStatusViewModel {
        premiumStatusViewModelFactory()
    }

    /// Show Premium Status on tap
    func showPremiumStatus() {
        self.isPresentingPremiumStatus = true
    }
}

// MARK: Premium upgrade offline
extension AccountViewModel {
    func showOfflinePremiumAlert() {
        isPresentingOfflineView = true
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
                // do not send user cancellations as errors to Sentry
                if let storeKitError = error as? StoreKitError, case .userCancelled = storeKitError {
                    return
                }
                Log.capture(message: "Manual purchase restore failed: \(error)")
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
