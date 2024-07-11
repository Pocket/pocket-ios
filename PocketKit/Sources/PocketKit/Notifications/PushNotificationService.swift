// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BrazeKit
import BrazeUI
import Sync
import Analytics
import SharedPocketKit
import Combine
import UIKit
import UserNotifications

protocol PushNotificationProtocol {
    /**
     We have a session indicating a login
     */
    func loggedIn(session: SharedPocketKit.Session)

    /**
     We have are either missing a session on app start, or we are logging out, but passing through the previous session for unregistration actions
     */
    func loggedOut(session: SharedPocketKit.Session?)

    /**
     Called when Apple sends us a new device token for APNS
     */
    func register(deviceToken: Data)

    /**
     Called when we receive a background notification from Apple.
     Returns true or false if it handled a notification
     */
    func handleBackgroundNotifcation(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool
}

/**
 Coordinator class that handles InstantSync, and Braze notifications from and to Apple.
 */
class PushNotificationService: NSObject {
    /**
     Instance of our API client for pulling in data when we recieve pushes.
     */
    private let source: Source

    /**
     Instance of the Pocket Analytics tracker
     */
    private let tracker: Tracker

    /**
     Instance of the Pocket Session manager for us to subscribe to
     */
    private let appSession: AppSession

    /**
     The Pocket braze protocol
     */
    private var braze: BrazeProtocol

    /**
     Instance of our Instant Sync engine
     */
    private let instantSync: InstantSyncProtocol

    /**
     App wide subscriptions that we listen to.
     */
    private var subscriptions: Set<AnyCancellable> = []

    init(source: Source, tracker: Tracker, appSession: AppSession, braze: BrazeProtocol, instantSync: InstantSyncProtocol) {
        self.source = source
        self.tracker = tracker
        self.appSession = appSession
        self.instantSync = instantSync
        self.braze = braze

        super.init()

        // Register for login notifications
        NotificationCenter.default.publisher(for: .userLoggedIn)
            .sink { [weak self] notification in
                guard let session = notification.object as? SharedPocketKit.Session  else {
                    Log.capture(message: "Logged in publisher in PocketNotificationService could not convert to session")
                    return
                }
                self?.loggedIn(session: session)
            }
            .store(in: &subscriptions)

        // Register for anonymous login notifications
        NotificationCenter.default.publisher(for: .anonymousLogin)
            .sink { [weak self] notification in
                guard let session = notification.object as? SharedPocketKit.Session  else {
                    Log.capture(message: "Logged in publisher in PocketNotificationService could not convert to session")
                    return
                }
                self?.loggedIn(session: session)
            }
            .store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(for: .userLoggedOut)
            .sink { [weak self] notification in
                guard let session = notification.object as? SharedPocketKit.Session  else {
                    Log.capture(message: "Logged out publisher in PocketNotificationService could not convert to session")
                    return
                }
                self?.loggedOut(session: session)
            }
            .store(in: &subscriptions)

        handleSessionInitilization(session: appSession.currentSession)
    }

    /**
     Handle session intitlization when not coming from a notification center subscriber. Mainly for app initilization.
     */
    private func handleSessionInitilization(session: SharedPocketKit.Session?) {
        guard let session = session else {
            loggedOut(session: nil)
            return
        }
        loggedIn(session: session)
    }

    /**
     Perform the following notification actions on Login:
     - Register with Braze
     - Register for provisional push notifications
     */
    private func loggedIn(session: SharedPocketKit.Session) {
        registerForRemoteNotificationsWithApple()
        braze.loggedIn(session: session)
        instantSync.loggedIn(session: session)
    }

    /**
     Perform the following notification actions on Logout:
     - Remove instant sync
     */
    private func loggedOut(session: SharedPocketKit.Session?) {
        unregisterForRemoteNotificationsWithApple()
        instantSync.loggedOut(session: session)
        braze.loggedOut(session: session)
    }
}

// MARK: Apple callbacks and specific functions
extension PushNotificationService {
    /**
     Deregister with Apple
     */
    private func unregisterForRemoteNotificationsWithApple() {
        // Unregister for REMOTE (not regular marketing) notifcations, i.e. Instant Sync.
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    /**
     Register with Apple
     */
    private func registerForRemoteNotificationsWithApple() {
        // Register for REMOTE (not regular marketing) notifcations, i.e. Instant Sync.
        UIApplication.shared.registerForRemoteNotifications()
    }

    /**
     AppDelegate has informed us of a new Apple token, send it to all the APNS protocl implementors.
     */
    public func register(deviceToken: Data) {
        braze.register(deviceToken: deviceToken)
        instantSync.register(deviceToken: deviceToken)
    }

    /**
     Proxy function to braze to handle background notifications
     */
    public func handleBackgroundNotifcation(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Forward background notification to Braze.
        if braze.handleBackgroundNotifcation(
            didReceiveRemoteNotification: userInfo,
            fetchCompletionHandler: completionHandler
        ) {
            // Braze handled the notification, nothing more to do.
            return
        }

        // Braze did not handle this remote background notification.
        // So that means it must bbe an instant sync notification!
        _ = instantSync.handleBackgroundNotifcation(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}
