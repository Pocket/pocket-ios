// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Sync
import SharedPocketKit

/**
 Extend the App Delegate so that we can add in the notification methods
 */
extension PocketAppDelegate {
    /**
     Called when Apple assigns us a Push notification token.
     */
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        notificationService.register(deviceToken: deviceToken)
    }

    /**
     Called when Apple gives us a notication in the background.
     */
    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        notificationService.handleBackgroundNotifcation(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    /**
     Called when push notifications fail to register with Apple
     */
    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
            Log.warning("Error registering for push notifications")
            Log.capture(error: error)
        }
}
