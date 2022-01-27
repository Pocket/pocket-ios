// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Analytics


struct Services {
    static let shared = Services()

    let userDefaults: UserDefaults
    let firstLaunchDefaults: UserDefaults
    let sessionController: SessionController
    let urlSession: URLSessionProtocol
    let source: Source
    let tracker: Tracker
    let sceneTracker: SceneTracker
    let refreshCoordinator: RefreshCoordinator

    private init() {
        userDefaults = .standard
        firstLaunchDefaults = UserDefaults(
            suiteName: "\(Bundle.main.bundleIdentifier!).first-launch"
        )!
        urlSession = URLSession.shared

        let session = Session(userDefaults: userDefaults)
        let keychain = SecItemKeychain()
        let accessTokenStore = KeychainAccessTokenStore(keychain: keychain)
        let authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            session: urlSession
        )

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        source = PocketSource(
            sessionProvider: session,
            accessTokenProvider: accessTokenStore,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            defaults: userDefaults
        )

        sceneTracker = SceneTracker(tracker: tracker, userDefaults: userDefaults)
        refreshCoordinator = RefreshCoordinator(taskScheduler: .shared)
        sessionController = SessionController(
            authClient: authClient,
            session: session,
            accessTokenStore: accessTokenStore,
            tracker: tracker,
            source: source,
            userDefaults: userDefaults
        )
    }
}

extension Session: SessionProvider { }
