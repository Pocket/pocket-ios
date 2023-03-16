// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Analytics
import AuthenticationServices
import BackgroundTasks
import SharedPocketKit
import Kingfisher

struct Services {
    static let shared = Services()

    let userDefaults: UserDefaults
    let firstLaunchDefaults: UserDefaults
    let appSession: AppSession
    let user: User
    let urlSession: URLSessionProtocol
    let source: Sync.Source
    let tracker: Tracker
    let sceneTracker: SceneTracker
    let refreshCoordinator: RefreshCoordinator
    let homeRefreshCoordinator: HomeRefreshCoordinator
    let authClient: AuthorizationClient
    let imageManager: ImageManager
    let notificationService: PushNotificationService
    let v3Client: V3ClientProtocol
    let instantSync: InstantSyncProtocol
    let braze: BrazeProtocol
    let appBadgeSetup: AppBadgeSetup
    let subscriptionStore: SubscriptionStore
    let userManagementService: UserManagementServiceProtocol

    private let persistentContainer: PersistentContainer

    private init() {
        userDefaults = .standard
        firstLaunchDefaults = UserDefaults(
            suiteName: "\(Bundle.main.bundleIdentifier!).first-launch"
        )!
        persistentContainer = .init(storage: .shared, userDefaults: firstLaunchDefaults, groupId: Keys.shared.groupId)

        urlSession = URLSession.shared

        appSession = AppSession(groupId: Keys.shared.groupId)
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            authenticationSessionFactory: ASWebAuthenticationSession.init
        )
        user = PocketUser(userDefaults: userDefaults)

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        source = PocketSource(
            space: persistentContainer.rootSpace,
            user: user,
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            defaults: userDefaults,
            backgroundTaskManager: UIApplication.shared
        )

        v3Client = V3Client.createDefault(
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey
        )

        sceneTracker = SceneTracker(tracker: tracker, userDefaults: userDefaults)

        refreshCoordinator = RefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            source: source,
            sessionProvider: appSession
        )

        homeRefreshCoordinator = HomeRefreshCoordinator(
            notificationCenter: .default,
            userDefaults: userDefaults,
            source: source,
            sessionProvider: appSession
        )

        imageManager = ImageManager(
            imagesController: source.makeUndownloadedImagesController(),
            imageRetriever: KingfisherManager.shared,
            source: source
        )
        imageManager.start()

        instantSync = InstantSync(
            appSession: appSession,
            source: source,
            v3Client: v3Client
        )

        braze = PocketBraze(
            apiKey: Keys.shared.brazeAPIKey,
            endpoint: Keys.shared.brazeAPIEndpoint,
            groupdId: Keys.shared.groupId
        )

        notificationService = PushNotificationService(
            source: source,
            tracker: tracker,
            appSession: appSession,
            braze: braze,
            instantSync: instantSync
        )

        appBadgeSetup = AppBadgeSetup(
            source: source,
            userDefaults: userDefaults,
            badgeProvider: UIApplication.shared
        )
        subscriptionStore = PocketSubscriptionStore(user: user, receiptService: AppStoreReceiptService())

        userManagementService = UserManagementService(appSession: appSession, user: user, notificationCenter: .default, source: source)
    }
}

extension AppSession: SessionProvider {
    public var session: Sync.Session? {
        currentSession
    }
}

extension SharedPocketKit.Session: Sync.Session { }
