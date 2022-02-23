// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Analytics
import AuthenticationServices


struct Services {
    static let shared = Services()

    let userDefaults: UserDefaults
    let firstLaunchDefaults: UserDefaults
    let appSession: AppSession
    let urlSession: URLSessionProtocol
    let source: Source
    let tracker: Tracker
    let sceneTracker: SceneTracker
    let refreshCoordinator: RefreshCoordinator
    let authClient: AuthorizationClient
    let sessionListener: SessionListener

    private init() {
        userDefaults = .standard
        firstLaunchDefaults = UserDefaults(
            suiteName: "\(Bundle.main.bundleIdentifier!).first-launch"
        )!
        urlSession = URLSession.shared

        appSession = AppSession()
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            urlSession: urlSession,
            authenticationSession: ASWebAuthenticationSession.self
        )

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        source = PocketSource(
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            defaults: userDefaults
        )

        sceneTracker = SceneTracker(tracker: tracker, userDefaults: userDefaults)
        refreshCoordinator = RefreshCoordinator(taskScheduler: .shared)

        sessionListener = SessionListener(
            appSession: appSession,
            authClient: authClient,
            tracker: tracker,
            source: source,
            userDefaults: userDefaults
        )
    }
}

extension AppSession: SessionProvider {
    var session: Sync.Session? {
        currentSession
    }
}

extension Session: Sync.Session { }
