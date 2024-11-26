// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SharedPocketKit

public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    private let services: Services
    private let notificationCenter: NotificationCenter
    let notificationService: PushNotificationService

    convenience override init() {
        self.init(services: .shared)
    }

    init(services: Services) {
        self.services = services
        self.notificationService = services.notificationService
        self.notificationCenter = services.notificationCenter

        super.init()
    }
}

// MARK: interface orientations
extension PocketAppDelegate {
    static var phoneOrientationLock = UIInterfaceOrientationMask.portrait

    public func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return .all }
        return Self.phoneOrientationLock
    }
}

// MARK: remote notifications
extension PocketAppDelegate {
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        notificationService.register(deviceToken: deviceToken)
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        notificationService.handleBackgroundNotifcation(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
            Log.warning("Error registering for push notifications")
            Log.capture(error: error)
        }
}
