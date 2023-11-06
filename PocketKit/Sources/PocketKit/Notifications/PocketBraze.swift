// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    func signedInUserDidBeginMigration()
}

/**
 Merged protocol to conform to our APNS protocol and the Braze Protocol
 */
typealias BrazeProtocol = BrazeSDKProtocol & PushNotificationProtocol

/**
 Class that is managing our Braze SDK implementation
 */
class PocketBraze: NSObject {
    /// Our Braze SDK Object
    let braze: Braze

    init(apiKey: String, endpoint: String, groupdId: String) {
        // Init Braze with our information.
        let configuration = Braze.Configuration(
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
            // Was this build deployed through the App Store or through TestFlight?
            var isTestFlight = false
            if let receiptURL = Bundle.main.appStoreReceiptURL {
                isTestFlight = receiptURL.path(percentEncoded: false).contains("sandboxreceipt")
            }
            // Could expand to include "development"
            let deployment = isTestFlight ? "testflight" : "app_store"
            self?.braze.user.setCustomAttribute(key: "deployment", value: deployment)
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

    // MARK: Push Notification Events

    func didReceiveUserNotification(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = braze.notifications.handleUserNotification(response: response, withCompletionHandler: completionHandler)
    }

    func register(deviceToken: Data) {
        braze.notifications.register(deviceToken: deviceToken)
    }

    func handleBackgroundNotifcation(didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        return braze.notifications.handleBackgroundNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

    // MARK: Migration Events

    func signedInUserDidBeginMigration() {
        braze.logCustomEvent(name: "SIGNED_IN_USER_UPGRADE_DID_START")
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
        // We need to set our scene for Braze because our UIKit + SwiftUI stuff does not seem to work with Braze's default
        // https://github.com/braze-inc/braze-swift-sdk/blob/d2ac02aad85418dd1b044bdaf7306b2e1d3e3822/Sources/BrazeUI/InAppMessageUI/InAppMessageUI.swift#L123-L127
        // Note: that if we ever introduce multiple scenes (CarPlay) we will need to update this.
        // Note: You can also test this code by putting the below code in the init function above.
        //        let modal: Braze.InAppMessage = .modal(
        //            .init(
        //              graphic: .icon("🙄"),
        //              header: "Header text",
        //              message: "Local modal in-app message"
        //            )
        //          )
        //
        //        DispatchQueue.main.async {
        //            inAppMessageUI.present(message: modal)
        //        }
        context.windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene)
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
