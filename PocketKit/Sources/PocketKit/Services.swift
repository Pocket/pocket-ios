// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Analytics


struct Services {
    static let shared = Services()

    let userDefaults: UserDefaults
    let session: Session
    let keychain: Keychain
    let accessTokenStore: AccessTokenStore
    let urlSession: URLSessionProtocol
    let authClient: AuthorizationClient
    let source: Source
    let tracker: Tracker
    let sceneTracker: SceneTracker

    private init() {
        userDefaults = .standard
        session = Session(userDefaults: userDefaults)
        keychain = SecItemKeychain()
        accessTokenStore = KeychainAccessTokenStore(keychain: keychain)

        urlSession = URLSession.shared
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            session: urlSession
        )

        source = Source(
            sessionProvider: session,
            accessTokenProvider: accessTokenStore,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            defaults: userDefaults
        )

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)
        
        sceneTracker = SceneTracker(tracker: tracker, userDefaults: userDefaults)
    }
}

extension Session: SessionProvider { }
