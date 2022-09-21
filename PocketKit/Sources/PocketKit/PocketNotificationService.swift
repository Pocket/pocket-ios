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
    private let sessionManager: AppSession

    /**
     Instance of our v3 Client to make legacy requests
     */
    private let v3Client: V3ClientProtocol

    /**
     App wide subscriptions that we listen to.
     */
    private var subscriptions: Set<AnyCancellable> = []

    init(source: Source, tracker: Tracker, sessionManager: AppSession, v3Client: V3ClientProtocol) {
        self.source = source
        self.tracker = tracker
        self.sessionManager = sessionManager
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

        sessionManager.$currentSession.sink { [weak self] session in
            guard let session = session else {
                self?.loggedOut()
                return
            }

            self?.loggedIn(session: session)
        }.store(in: &subscriptions)
    }

    /**
     Perform the following notification actions on Login:
     - Register with Braze
     - Register for provisional push notifications
     - ONLY CALL THIS FROM THE MAIN THREAD So that ui can happen and for braze registration
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
    }

    /**
     Perform the following notification actions on Logout:
     - Remove instant sync
     */
    private func loggedOut() {
        // TODO: Re-enable in a followup pr when we act on instant sync

//        Task {
//            do {
//                _ = try await v3Client.deregisterPushToken(for: Device.current.deviceIdentifer(), pushType: PocketNotificationService.pushType())
//            } catch {
//                Crashlogger.capture(error: error)
//            }
//        }
    }

    /**
     Proxy function to braze to register a device token
     */
    public func register(deviceToken: Data) {
        // TODO: Also register the token with the Pocket Instant Sync endpoint
        braze.notifications.register(deviceToken: deviceToken)

        // TODO: Re-enable in a followup pr when we act on instant sync
//        Task {
//            do {
//                _ = try await v3Client.registerPushToken(for: Device.current.deviceIdentifer(), pushType: PocketNotificationService.pushType(), token: deviceToken.base64EncodedString())
//            } catch {
//                Crashlogger.capture(error: error)
//            }
//        }
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
        // We can handle the notification yourself here.
        // TODO: Handle the V3 Instant sync push notification.

        // Manually call the completion handler to let the system know
        // that the background notification is processed.
        completionHandler(.noData)
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

    static func pushType() -> PushType {
        // TODO: Once we move to the main app store bundle, we will need to move this to say prod when built
        // for that identifier and alpha when built for Alpha Neue
        var pushType: PushType = .alpha
#if DEBUG
        pushType = .alphadev
#endif
        return pushType
    }
}
