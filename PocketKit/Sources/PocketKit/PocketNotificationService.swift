import Foundation
import BrazeKit
import BrazeUI
import Sync
import Analytics
import SharedPocketKit
import Combine
import UIKit
import UserNotifications

class PocketNotificationService: NSObject {

    /**
     The Braze service object
     */
    private let braze: Braze

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
     Instance of our v3 Client to make legacy requests
     */
    private let v3Client: V3ClientProtocol

    /**
     App wide subscriptions that we listen to.
     */
    private var subscriptions: Set<AnyCancellable> = []

    init(source: Source, tracker: Tracker, appSession: AppSession, v3Client: V3ClientProtocol) {
        self.source = source
        self.tracker = tracker
        self.appSession = appSession
        self.v3Client = v3Client

        // Init Braze with our information.
        var configuration = Braze.Configuration(
            apiKey: Keys.shared.brazeAPIKey,
            endpoint: Keys.shared.brazeAPIEndpoint
        )

        // Enable logging of general SDK information (e.g. user changes, etc.)
        configuration.logger.level = .info
        configuration.push.appGroup = "group.com.ideashower.ReadItLaterProAlp"
        braze = Braze(configuration: configuration)
        super.init()

        // Set up the in app message ui
        let inAppMessageUI = BrazeInAppMessageUI()
        inAppMessageUI.delegate = self
        braze.inAppMessagePresenter = inAppMessageUI

        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                Crashlogger.capture(message: "Logged in publisher in PocketNotificationService could not convert to session")
                return
            }
            self?.loggedIn(session: session)
        }.store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                Crashlogger.capture(message: "Logged out publisher in PocketNotificationService could not convert to session")
                return
            }
            self?.loggedOut(session: session)
        }.store(in: &subscriptions)

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
        self.loggedIn(session: session)
    }

    /**
     Perform the following notification actions on Login:
     - Register with Braze
     - Register for provisional push notifications
     */
    private func loggedIn(session: SharedPocketKit.Session) {
        DispatchQueue.main.async { [weak self] in
            // Braze SDK docs say this needs to be called from the main thread.
            // https://www.braze.com/docs/developer_guide/platform_integration_guides/ios/analytics/setting_user_ids/#assigning-a-user-id
            self?.braze.changeUser(userId: session.userIdentifier)
        }

        let center = UNUserNotificationCenter.current()
        // In the future we can setup other types of categories
        // https://www.braze.com/docs/user_guide/message_building_by_channel/push/ios/notification_options/#summary-arguments
        center.setNotificationCategories(Braze.Notifications.categories)
        center.delegate = self
        // We also ask for provisional authotization which is in iOS 12 and above and allows us to use push notifications that only post to the notification center
        // https://www.braze.com/docs/user_guide/message_building_by_channel/push/ios/notification_options/#provisional-push
        // Developer Note: Since we are registering provisional push, the user will never see the pop up to allow push notifications.
        // This can make it challenging to test push notification registration flows because you will not see push registration appear, so you may want to remove this during active development.
        center.requestAuthorization(options: [.badge, .sound, .alert, .provisional]) { granted, error in
            print("Notification authorization, granted: \(granted), error: \(String(describing: error))")
        }

        // Register for REMOTE (not regular marketing) notifcations, i.e. Instant Sync.
        UIApplication.shared.registerForRemoteNotifications()
    }

    /**
     Perform the following notification actions on Logout:
     - Remove instant sync
     */
    private func loggedOut(session: SharedPocketKit.Session?) {
        // Unregister for REMOTE (not regular marketing) notifcations, i.e. Instant Sync.
        UIApplication.shared.unregisterForRemoteNotifications()

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
                Crashlogger.capture(error: error)
            }
        }
    }

    /**
     Proxy function to braze to register a device token
     */
    public func register(deviceToken: Data) {
        braze.notifications.register(deviceToken: deviceToken)

        // Check if we have a current session
        guard let session = appSession.currentSession else {
            // We do not have a session so we can not register for push notifications.
            // Capture the message for later use and move on.
            Crashlogger.capture(message: "Push Notification Service has no current session to use to register a push token with")
            return
        }

        Task {[weak self] in
            do {
                _ = try await self?.v3Client.registerPushToken(for: DeviceUtilities.deviceIdentifer(), pushType: pushType, token: deviceToken.base64EncodedString(), session: session)
            } catch {
                Crashlogger.capture(error: error)
            }
        }
    }

    /**
     Proxy function to braze to handle background notifications
     */
    public func handleBackgroundNotifcation(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {

        // Forward background notification to Braze.
        if braze.notifications.handleBackgroundNotification(
            userInfo: userInfo,
            fetchCompletionHandler: completionHandler
        ) {
            // Braze handled the notification, nothing more to do.
            return
        }

        // Braze did not handle this remote background notification.
        // So that means it must bbe an instant sync notification!
        handleInstantSync(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    /**
     Proxy function to Braze to handle user facing notifications
     */
    public func didRecieveUserNotifcation(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        _ = braze.notifications.handleUserNotification(response: response, withCompletionHandler: completionHandler)
    }
}

/**
 Extend the Notification service to support User Notifications
 */
extension PocketNotificationService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        didRecieveUserNotifcation(center, didReceive: response, withCompletionHandler: completionHandler)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner])
    }
}

/**
 Extend the Notification service to support Braze InApp Message UI
 */
extension PocketNotificationService: BrazeInAppMessageUIDelegate {

    func inAppMessage(
        _ ui: BrazeInAppMessageUI,
        prepareWith context: inout BrazeInAppMessageUI.PresentationContext
    ) {
        // Customize the in-app message presentation here using the context
    }

    func inAppMessage(
        _ ui: BrazeInAppMessageUI,
        didPresent message: Braze.InAppMessage,
        view: InAppMessageView
    ) {
        // Executed when `message` is presented to the user
    }
}

/**
 V3 Helpers
 */
extension PocketNotificationService {
    var pushType: PushType {
        var type: PushType = .alpha
#if DEBUG
        type = .alphadev
#endif
        return type
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

        triggerSyncFromRemotePush(fetchCompletionHandler: completionHandler)
    }

    /**
     Triggers our sync process when told to via a remote push
     */
    func triggerSyncFromRemotePush(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.source.refresh {
            completionHandler(.newData)
        }
        self.source.retryImmediately()
    }
}
