// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit
import Combine
import Analytics

struct Services {
    static let shared = Services()

    let appSession: AppSession
    let saveService: PocketSaveService
    let user: User
    let tracker: Tracker
    let userDefaults: UserDefaults
    let notificationCenter: NotificationCenter
    let braze: SaveToBraze

    /// The user management service that will log a user out when the correct notification is posted.
    /// This is marked as private since we do not need to access it, but we need it to be around for the lifetime
    /// of a Services instance. When using `.shared`, this lifetime will exist for the duration of the share extension.
    private let userManagementService: SaveToUserManagementServiceProtocol

    private let persistentContainer: PersistentContainer

    private init() {
        Log.start(dsn: Keys.shared.sentryDSN)

        guard let sharedUserDefaults = UserDefaults(suiteName: Keys.shared.groupID) else {
            fatalError("UserDefaults with suite name \(Keys.shared.groupID) must exist.")
        }
        userDefaults = sharedUserDefaults

        notificationCenter = .default

        persistentContainer = .init(storage: .shared, groupID: Keys.shared.groupID)

        appSession = AppSession(groupID: Keys.shared.groupID)

        user = PocketUser(userDefaults: userDefaults)

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        saveService = PocketSaveService(
            space: persistentContainer.rootSpace,
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            expiringActivityPerformer: ProcessInfo.processInfo,
            recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService(store: UserDefaultsItemWidgetsStore(userDefaults: userDefaults, key: .recentSavesWidget))
        )

        braze = SaveToBraze(
            apiKey: Keys.shared.brazeAPIKey,
            endpoint: Keys.shared.brazeAPIEndpoint,
            groupdID: Keys.shared.groupID
        )

        userManagementService = SaveToUserManagementService(appSession: appSession, user: user, notificationCenter: notificationCenter)
    }

    /// Starts up all services as required.
    /// - Parameter onReset: The function to call if a service has been reset.
    /// - Note: `onReset` can be called when a migration within the persistent container fails.
    func start(onReset: @escaping () -> Void) {
        if persistentContainer.didReset {
            onReset()
        }
    }
}
