// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import Sync
import Combine
import Textile
import SharedPocketKit
import UIKit
import Adjust

@MainActor
public class RootViewModel: ObservableObject {
    @Published var mainViewModel: MainViewModel?
    @Published var loggedOutViewModel: LoggedOutViewModel?
    @Published var isLoggedIn = false

    private let appSession: AppSession
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults
    private let widgetsSessionService: WidgetsSessionService
    private let router: Router

    private var subscriptions: Set<AnyCancellable> = []

    public convenience init() {
        self.init(appSession: Services.shared.appSession, tracker: Services.shared.tracker, source: Services.shared.source, userDefaults: Services.shared.userDefaults, widgetsSessionService: Services.shared.widgetsSessionService, router: Services.shared.router)
    }

    init(
        appSession: AppSession,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults,
        widgetsSessionService: WidgetsSessionService,
        router: Router
    ) {
        self.appSession = appSession
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults
        self.widgetsSessionService = widgetsSessionService
        self.router = router

        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] notification in
            self?.handleSession(session: notification.object as? SharedPocketKit.Session)
        }.store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] notification in
            self?.handleSession(session: nil)
        }.store(in: &subscriptions)

        // Because session could already be available at init, lets try and use it.
        handleSession(session: appSession.currentSession)
    }

    /**
     Handles a session if it exists.
     */
    func handleSession(session: SharedPocketKit.Session?) {
        guard let session = session else {
            // If the session is nil, ensure the user's view is logged out
            self.tearDownSession()
            self.mainViewModel = nil
            self.loggedOutViewModel = LoggedOutViewModel()
            return
        }

        // We have a session! Ensure the user is logged in.
        self.setUpSession(session)
        self.mainViewModel = MainViewModel()
        self.loggedOutViewModel = nil
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey),
            UserEntity(guid: session.guid, userID: session.userIdentifier, adjustAdId: Adjust.adid())
        ])
        widgetsSessionService.setLoggedIn(true)
        Log.setUserID(session.userIdentifier)
    }

    private func tearDownSession() {
        source.clear()
        widgetsSessionService.setLoggedIn(false)
        userDefaults.resetKeys()

        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        Log.clearUser()
        Textiles.clearImageCache()
    }
}

// MARK: URL handling
extension RootViewModel {
    func handleUrl(_ url: URL) {
        router.handle(url: url)
    }
}
