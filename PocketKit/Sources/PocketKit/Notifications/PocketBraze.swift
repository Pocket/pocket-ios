import Foundation
import BrazeUI
import BrazeKit
import UserNotifications
import SharedPocketKit
import UIKit
import Sync

protocol BrazeSDKProtocol {
    func didReceiveUserNotification(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
}

/**
 Merged protocol to conform to our APNS protocol and the Braze Protocol
 */
typealias BrazeProtocol = BrazeSDKProtocol & PushNotificationProtocol

/**
 Class that is managing our Braze SDK implementation
 */
class PocketBraze: NSObject {
    /**
     Our Braze SDK Object
     */
    let braze: Braze

    init(apiKey: String, endpoint: String, groupdId: String) {
        // Init Braze with our information.
        var configuration = Braze.Configuration(
            apiKey: apiKey,
            endpoint: endpoint
        )

        // Enable logging of general SDK information (e.g. user changes, etc.)
        configuration.logger.level = .info
        configuration.push.appGroup = groupdId
        braze = Braze(configuration: configuration)

        super.init()

        // Set up the in app message ui
        let inAppMessageUI = BrazeInAppMessageUI()
        inAppMessageUI.delegate = self
        braze.inAppMessagePresenter = inAppMessageUI
    }
}

/**
 Conforming to our PocketBraze Protocol
 */
extension PocketBraze: BrazeProtocol {
    func loggedIn(session: SharedPocketKit.Session) {
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
            Log.info("Notification authorization, granted: \(granted), error: \(String(describing: error))")
        }
    }

    func loggedOut(session: SharedPocketKit.Session?) {
        // Waiting on braze support to understand logout
    }

    func didReceiveUserNotification(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = braze.notifications.handleUserNotification(response: response, withCompletionHandler: completionHandler)
    }

    func register(deviceToken: Data) {
        braze.notifications.register(deviceToken: deviceToken)
    }

    func handleBackgroundNotifcation(didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        return braze.notifications.handleBackgroundNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}

/**
 Extend the Notification service to support Braze InApp Message UI
 */
extension PocketBraze: BrazeInAppMessageUIDelegate {
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
 Extend the Notification service to support User Notifications
 */
extension PocketBraze: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        didReceiveUserNotification(center, didReceive: response, withCompletionHandler: completionHandler)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner])
    }
}
