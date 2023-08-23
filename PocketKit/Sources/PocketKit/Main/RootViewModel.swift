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
import Localization
import SwiftUI

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
    private let notificationCenter: NotificationCenter
    private let refreshCoordinators: [RefreshCoordinator]

    private var subscriptions: Set<AnyCancellable> = []

    public convenience init() {
        self.init(services: Services.shared)
    }

    private convenience init(services: Services) {
        self.init(
            appSession: Services.shared.appSession,
            tracker: Services.shared.tracker,
            source: Services.shared.source,
            userDefaults: Services.shared.userDefaults,
            widgetsSessionService: Services.shared.widgetsSessionService,
            notificationCenter: Services.shared.notificationCenter,
            refreshCoordinators: Services.shared.refreshCoordinators
        )

        services.start { [weak self] in
            guard let self else { return }
            self.persistentContainerDidReset()
        }
    }

    init(
        appSession: AppSession,
        tracker: Tracker,
        source: Source,
        userDefaults: UserDefaults,
        widgetsSessionService: WidgetsSessionService,
        notificationCenter: NotificationCenter,
        refreshCoordinators: [RefreshCoordinator]
    ) {
        self.appSession = appSession
        self.tracker = tracker
        self.source = source
        self.userDefaults = userDefaults
        self.widgetsSessionService = widgetsSessionService
        self.notificationCenter = notificationCenter
        self.refreshCoordinators = refreshCoordinators
    }

    public func start() {
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

    /// Performs actions based on the result of the Services persistent container being reset.
    private func persistentContainerDidReset() {
        // Since there will be a loss of on-disk data during a reset (read: destroy / add), we want
        // to perform the same type of sync we would on initial login. An example use case is Home - there is
        // a possibility that Home _had_ content, but the app was updated (with a failed migration) before the
        // next allowed refresh interval for Home. Thus, Home wouldn't load data. This is similar across other
        // portions of the app, such as a user's items.
        refreshCoordinators.forEach { $0.refresh(isForced: true) { } }

        // Upon reset, let the user know (as a toast) that a problem occurred, and that we're redownloading their data
        let data = BannerModifier.BannerData(
            image: .error,
            title: Localization.Error.problemOccurred,
            detail: Localization.Error.redownloading
        )
        notificationCenter.post(name: .bannerRequested, object: data)
    }

    /// Called when a `ScenePhase` change to active has been detected by the SwiftUI
    ///  lifecycle (in `PocketApp`, forwarded to here.
    public func scenePhaseDidChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            // Upon becoming active, if an extension (e.g SaveTo) requested that we force-refresh the app (e.g due to a
            // persistent container reset), then perform the same reset logic as if the app had explicitly performed a reset.
            if userDefaults.bool(forKey: .forceRefreshFromExtension) {
                persistentContainerDidReset()
                userDefaults.set(false, forKey: .forceRefreshFromExtension)
            }
        default: return
        }
    }
}
