// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import Foundation
import SharedPocketKit
import Sync

@MainActor
class DeleteAccountViewModel: ObservableObject {
    @Published var isPresentingCancelationHelp: Bool
    @Published var isDeletingAccount: Bool
    @Published var showErrorAlert: Bool

    let isPremium: Bool

    private let userManagementService: UserManagementServiceProtocol
    private let tracker: Tracker

    init(isPresentingCancellationHelp: Bool = false,
         isDeletingAccount: Bool = false,
         showErrorAlert: Bool = false,
         isPremium: Bool,
         userManagementService: UserManagementServiceProtocol,
         tracker: Tracker) {
        self.isPresentingCancelationHelp = isPresentingCancellationHelp
        self.isDeletingAccount = isDeletingAccount
        self.showErrorAlert = showErrorAlert
        self.isPremium = isPremium
        self.userManagementService = userManagementService
        self.tracker = tracker
    }

    /// Calls the user management service to delete the account and log the user out.
    func deleteAccount() {
        trackConfirmDeleteTapped()
        isDeletingAccount = true
        Task {
            do {
                try await userManagementService.deleteAccount()
            } catch {
                Log.capture(error: error)
                self.showErrorAlert = true
            }
            isDeletingAccount = false
        }
    }
}

// MARK: Delete Account Flow
extension DeleteAccountViewModel {
    /// track delete settings row tapped
    func trackDeleteTapped() {
        tracker.track(event: Events.Settings.deleteRowTapped())
    }

    /// track premium help tapped
    func trackHelpCancelingPremiumTapped() {
        tracker.track(event: Events.Settings.helpCancelingPremiumTapped())
    }

    /// track delete confirmation viewed
    func trackDeleteConfirmationImpression() {
        tracker.track(event: Events.Settings.deleteConfirmationImpression())
    }

    /// track premium help viewed
    func trackHelpCancelingPremiumImpression() {
        tracker.track(event: Events.Settings.helpCancelingPremiumImpression())
    }

    /// track delete tapped
    func trackConfirmDeleteTapped() {
        tracker.track(event: Events.Settings.deleteConfirmationTapped())
    }

    /// track cancel delete tapped
    func trackDeleteDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button, .closeButton:
            tracker.track(event: Events.Settings.deleteDismissed(reason: dismissReason))
        case .system:
            break
        }
    }
    /// Help canceling premium tapped
    func helpCancelPremium() {
        trackHelpCancelingPremiumTapped()
        isPresentingCancelationHelp = true
    }
}
