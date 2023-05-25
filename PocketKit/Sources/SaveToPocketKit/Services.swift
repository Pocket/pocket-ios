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
            expiringActivityPerformer: ProcessInfo.processInfo
        )

        braze = SaveToBraze(
            apiKey: Keys.shared.brazeAPIKey,
            endpoint: Keys.shared.brazeAPIEndpoint,
            groupdID: Keys.shared.groupID
        )
    }
}
