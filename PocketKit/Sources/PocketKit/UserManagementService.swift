// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Sync
import Combine

protocol UserManagementServiceProtocol {
    func deleteAccount() async throws
    func logout()
    var accountDeletedPublisher: Published<Bool>.Publisher { get }
    var accountDeleted: Bool { get }
}

final class UserManagementService: ObservableObject, UserManagementServiceProtocol {
    let appSession: AppSession
    let user: User
    let notificationCenter: NotificationCenter
    let source: Source

    // Deletion state
    @Published public private(set) var accountDeleted: Bool = false
    var accountDeletedPublisher: Published<Bool>.Publisher { $accountDeleted }

    init(appSession: AppSession, user: User, notificationCenter: NotificationCenter, source: Source) {
        self.appSession = appSession
        self.user = user
        self.notificationCenter = notificationCenter
        self.source = source
    }

    func deleteAccount() async throws {
        try await source.deleteAccount()
        accountDeleted = true
        await logout()
    }

    func loggedIn() {
        accountDeleted = false
    }

    @MainActor
    /// Logs out the user
    /// We do this on the main thread because the Notification Center will post to areas that will change the UI
    func logout() {
        // Post that we logged out to the rest of the app using the old session
        notificationCenter.post(name: .userLoggedOut, object: appSession.currentSession)
        user.clear()
        appSession.currentSession = nil
    }
}
