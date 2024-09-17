// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Sync
import Combine

protocol SaveToUserManagementServiceProtocol {
    func logout()
}

final class SaveToUserManagementService: ObservableObject, SaveToUserManagementServiceProtocol {
    let appSession: AppSession
    let user: User
    let notificationCenter: NotificationCenter
    let client: V3ClientProtocol

    // Deletion state
    @Published public private(set) var accountDeleted: Bool = false
    var accountDeletedPublisher: Published<Bool>.Publisher { $accountDeleted }

    private var subscriptions: Set<AnyCancellable> = []

    init(
        appSession: AppSession,
        user: User,
        notificationCenter: NotificationCenter,
        client: V3ClientProtocol
    ) {
        self.appSession = appSession
        self.user = user
        self.notificationCenter = notificationCenter
        self.client = client

        notificationCenter
            .publisher(for: .unauthorizedResponse)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.logout()
                }
            }
            .store(in: &subscriptions)
    }

    /// Logs out the user
    /// We do this on the main thread because the Notification Center will post to areas that will change the UI
    @MainActor
    func logout() {
    user.clear()
        Task { @MainActor in
            do {
                let guid = try await client.fetchAnonymousGuid()
                appSession.setAnonymousSession(guid)
            } catch {
                Log.capture(message: "Unable to fetch anonymous guid \(error)")
                // this will still ensure that users can use the signed out features, we don't want
                // the app to fail even if we're not able to track analytics.
                appSession.setAnonymousSession("")
            }
        }
    }
}
