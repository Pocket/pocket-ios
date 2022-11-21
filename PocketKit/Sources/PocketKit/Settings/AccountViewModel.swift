import Sync
import Analytics
import Textile
import Foundation
import SharedPocketKit
import SwiftUI

class AccountViewModel: ObservableObject {
    static let ToggleAppBadgeKey = "AccountViewModel.ToggleAppBadge"
    private let appSession: AppSession
    private let user: User
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    @AppStorage("Settings.ToggleAppBadge")
    public var appBadgeToggle: Bool = false

    init(appSession: AppSession, user: User, userDefaults: UserDefaults, notificationCenter: NotificationCenter) {
        self.appSession = appSession
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.user = user
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

    @Published var isPresentingHelp = false
    @Published var isPresentingTerms = false
    @Published var isPresentingPrivacy = false
    @Published var isPresentingSignOutConfirm = false
}
