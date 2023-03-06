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
}

struct UserManagementService: UserManagementServiceProtocol {
    let appSession: AppSession
    let user: User
    let notificationCenter: NotificationCenter
    let source: Source

    func deleteAccount() async throws {
        try await source.deleteAccount()
        logout()
        self.notificationCenter.post(name: .userDeleted, object: nil)
    }

    func logout() {
        // Post that we logged out to the rest of the app using the old session
        notificationCenter.post(name: .userLoggedOut, object: appSession.currentSession)
        user.clear()
        appSession.currentSession = nil
    }
}
