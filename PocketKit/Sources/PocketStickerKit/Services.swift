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
    let user: User
    let tracker: Tracker
    let userDefaults: UserDefaults
    let notificationCenter: NotificationCenter
    let braze: StickerBraze

    private init() {
        Log.start(dsn: Keys.shared.sentryDSN)

        guard let sharedUserDefaults = UserDefaults(suiteName: Keys.shared.groupID) else {
            fatalError("UserDefaults with suite name \(Keys.shared.groupID) must exist.")
        }
        userDefaults = sharedUserDefaults

        notificationCenter = .default

        appSession = AppSession(groupID: Keys.shared.groupID)
        user = PocketUser(userDefaults: userDefaults)

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        braze = StickerBraze(
            apiKey: Keys.shared.brazeAPIKey,
            endpoint: Keys.shared.brazeAPIEndpoint,
            groupdID: Keys.shared.groupID
        )

        if let session = appSession.currentSession {
            braze.loggedIn(session: session)
        } else {
            braze.loggedOut(session: nil)
        }
    }
}
