// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit
import UIKit

protocol BaseInstantSyncProtocol {
    func handleInstantSync(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
}

/**
 Merges the APNS protocol with the Instant Sync Protocol
 */
typealias InstantSyncProtocol = PushNotificationProtocol & BaseInstantSyncProtocol

/**
 Class that manages the Instant Sync part of Pocket.
 */
class InstantSync: NSObject {
    let appSession: AppSession
    let source: Source
    let v3Client: V3ClientProtocol

    var pushType: PushType {
        var type: PushType = .prod
#if ALPHA_NEUE && DEBUG
        type = .alphadev
#elseif ALPHA_NEUE
        type = .alpha
#elseif DEBUG
        type = .proddev
#endif
        return type
    }

    init(appSession: AppSession, source: Source, v3Client: V3ClientProtocol) {
        self.appSession = appSession
        self.source = source
        self.v3Client = v3Client
        super.init()
    }

    /**
     Triggers our sync process when told to via a remote push
     */
    func triggerSyncFromRemotePush(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.source.refreshSaves {
            completionHandler(.newData)
        }
        self.source.retryImmediately()
    }
}

/**
 Conforming InstantSync to the InstantSyncProtocol
 */
extension InstantSync: InstantSyncProtocol {
    func loggedIn(session: SharedPocketKit.Session) {
        // Instant sync does not need to do anything on login, we only register tokens when we recieve one.
        // This is to conform to the APNS protocol
    }

    func loggedOut(session: SharedPocketKit.Session?) {
        // Check if we got a session from our caller
        guard let session = session else {
            // We do not have a session so we can not deregister for push notifications.
            // This is likely because the app opened to the login screen where we would have not had a session beforehand.
            return
        }

        Task {[weak self] in
            do {
                _ = try await self?.v3Client.deregisterPushToken(for: DeviceUtilities.deviceIdentifer(), pushType: pushType, session: session)
            } catch {
                Log.capture(error: error)
            }
        }
    }

    func register(deviceToken: Data) {
        // Check if we have a current session
        guard let session = appSession.currentSession else {
            // We do not have a session so we can not register for push notifications.
            // Capture the message for later use and move on.
            Log.capture(message: "Push Notification Service has no current session to use to register a push token with")
            Log.breadcrumb(category: "sync", level: .error, message: "AppSession.CurrentSession failed with error")
            return
        }

        Task {[weak self] in
            do {
                _ = try await self?.v3Client.registerPushToken(for: DeviceUtilities.deviceIdentifer(), pushType: pushType, token: deviceToken.base64EncodedString(), session: session)
            } catch {
                Log.capture(error: error)
                Log.breadcrumb(category: "sync", level: .error, message: "Registering Push notification failed with session: \(session)")
            }
        }
    }

    /**
     Recieved a background notification
     */
    func handleBackgroundNotifcation(didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        self.handleInstantSync(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        return true
    }

    /**
     Handle our Instant Sync push notification
     */
    func handleInstantSync(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let session = appSession.currentSession else {
            // The user is not logged in, so we ignore the instant sync.
            completionHandler(.noData)
            return
        }

        guard let pushGuid = userInfo["g"] as? String else {
            // The push does not contain a guid to check, lets instant sync!
            // As of 9/23/2022 most, if not all, Instant Syncs fall into this bucket.
            triggerSyncFromRemotePush(fetchCompletionHandler: completionHandler)
            return
        }

        guard pushGuid == session.guid else {
            // The push contains a guid that is equal to our current guid.
            // This means that the instant sync is because we ourselves performed an action that triggered the remote push.
            // Because of this we ignore this instant sync!
            completionHandler(.noData)
            return
        }

        // The guid we got in the push does not match our current GUID, lets Instant Sync!
        triggerSyncFromRemotePush(fetchCompletionHandler: completionHandler)
    }
}
