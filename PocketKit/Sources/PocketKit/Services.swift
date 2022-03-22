// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Analytics
import AuthenticationServices
import BackgroundTasks
import SharedPocketKit


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

    private init() {
        userDefaults = .standard
        firstLaunchDefaults = UserDefaults(
            suiteName: "\(Bundle.main.bundleIdentifier!).first-launch"
        )!
        urlSession = URLSession.shared

        appSession = AppSession()
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            authenticationSessionFactory: ASWebAuthenticationSession.init
        )

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        source = PocketSource(
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            defaults: userDefaults,
            backgroundTaskManager: UIApplication.shared
        )

        sceneTracker = SceneTracker(tracker: tracker, userDefaults: userDefaults)
        refreshCoordinator = RefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            source: source
        )
    }
}

extension AppSession: SessionProvider {
    public var session: Sync.Session? {
        currentSession
    }
}

extension SharedPocketKit.Session: Sync.Session { }
