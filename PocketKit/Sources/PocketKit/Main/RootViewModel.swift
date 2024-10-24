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
import AppIntents

@MainActor
public class RootViewModel: ObservableObject {
    enum ViewState {
        case loggedIn(MainViewModel)
        case anonymous(MainViewModel)
        case loggedOut(LoggedOutViewModel)
    }

    /// determines the state of RootView at any given moment
    @Published private(set) var viewState: ViewState?

    private let appSession: AppSession
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults
    private let widgetsSessionService: WidgetsSessionService
    private let notificationCenter: NotificationCenter
    private let refreshCoordinators: [RefreshCoordinator]

    private var subscriptions: Set<AnyCancellable> = []

    private var mainViewModel: MainViewModel?

    public convenience init() {
        self.init(services: Services.shared)
    }

    private convenience init(services: Services) {
        self.init(
            appSession: services.appSession,
            tracker: services.tracker,
            source: services.source,
            userDefaults: services.userDefaults,
            widgetsSessionService: services.widgetsSessionService,
            notificationCenter: services.notificationCenter,
            refreshCoordinators: services.refreshCoordinators
        )

        services.start { [weak self] in
            guard let self else { return }
            self.persistentContainerDidReset()
        }
        AppDependencyManager.shared.add(dependency: self.mainViewModel)
        startObservingLogin()
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

    private func startObservingLogin() {
        initializeSession(session: appSession.currentSession)
        appSession
            .$currentSession
            .receive(on: DispatchQueue.main)
            .dropFirst() // drop the value at init time
            .sink { [weak self] session in
                self?.updateSession(session)
            }
            .store(in: &subscriptions)
    }

    /// Handle session changes published by `AppSession`
    /// - Parameter newSession: the new session
    private func updateSession(_ newSession: SharedPocketKit.Session?) {
        tearDownSession()
        guard let newSession else {
            viewState = .loggedOut(LoggedOutViewModel())
            NotificationCenter.default.post(name: .userLoggedOut, object: nil)
            return
        }
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey),
            UserEntity(guid: newSession.guid, userID: newSession.userIdentifier, adjustAdId: Adjust.adid())
        ])

        if newSession.isAnonymous {
            let mainViewModel = MainViewModel()
            self.mainViewModel = mainViewModel
            viewState = .anonymous(mainViewModel)
            NotificationCenter.default.post(name: .anonymousAccess, object: newSession)
            widgetsSessionService.setStatus(.anonymous)
        } else {
            let mainViewModel = MainViewModel()
            self.mainViewModel = mainViewModel
            Log.setUserID(newSession.userIdentifier)
            viewState = .loggedIn(mainViewModel)
            NotificationCenter.default.post(name: .userLoggedIn, object: newSession)
            widgetsSessionService.setStatus(.loggedIn)
        }
    }

    /// Initialize session at app launch
    /// - Parameter session: the current session
    private func initializeSession(session: SharedPocketKit.Session?) {
        guard let session = session else {
            // If the session is nil, ensure the user's view is logged out
            tearDownSession()
            viewState = .loggedOut(LoggedOutViewModel())
            return
        }

        // We have a session! Ensure the user is logged in.
        setUpSession(session)
        let mainViewModel = MainViewModel()
        self.mainViewModel = mainViewModel
        viewState = session.isAnonymous ? .anonymous(mainViewModel) : .loggedIn(mainViewModel)
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey),
            UserEntity(guid: session.guid, userID: session.userIdentifier, adjustAdId: Adjust.adid())
        ])
        if !session.isAnonymous {
            widgetsSessionService.setStatus(.loggedIn)
            Log.setUserID(session.userIdentifier)
        } else {
            widgetsSessionService.setStatus(.anonymous)
        }
    }

    private func tearDownSession() {
        mainViewModel = nil
        source.clear()
        widgetsSessionService.setStatus(.loggedOut)
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
        // to perform the same type of sync we would on initial login, if users are logged in.
        // An example use case is Home - there is a possibility that Home _had_ content,
        // but the app was updated (with a failed migration) before the
        // next allowed refresh interval for Home. Thus, Home wouldn't load data. This is similar across other
        // portions of the app, such as a user's items.
        if appSession.currentSession != nil {
            refreshCoordinators.forEach { $0.refresh(isForced: true) { } }
        }

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
