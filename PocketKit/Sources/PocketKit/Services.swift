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
    static let shared: Services = { Services() }()

    let userDefaults: UserDefaults
    let firstLaunchDefaults: UserDefaults
    let appSession: AppSession
    let user: User
    let urlSession: URLSessionProtocol
    let source: Sync.Source
    let tracker: Tracker
    let sceneTracker: SceneTracker
    let savesRefreshCoordinator: SavesRefreshCoordinator
    let archiveRefreshCoordinator: ArchiveRefreshCoordinator
    let tagsRefreshCoordinator: TagsRefreshCoordinator
    let unresolvedSavesRefreshCoordinator: UnresolvedSavesRefreshCoordinator
    let homeRefreshCoordinator: HomeRefreshCoordinator
    let refreshCoordinators: [AbstractRefreshCoordinator]
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
        persistentContainer = .init(storage: .shared, userDefaults: firstLaunchDefaults, groupID: Keys.shared.groupID)

        urlSession = URLSession.shared

        appSession = AppSession(groupID: Keys.shared.groupID)
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            adjustSignupEventToken: Keys.shared.adjustSignUpEventToken,
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

        savesRefreshCoordinator = SavesRefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        archiveRefreshCoordinator = ArchiveRefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        tagsRefreshCoordinator = TagsRefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        unresolvedSavesRefreshCoordinator = UnresolvedSavesRefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        homeRefreshCoordinator = HomeRefreshCoordinator(
            notificationCenter: .default,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source,
            userDefaults: userDefaults
        )

        refreshCoordinators = [
            savesRefreshCoordinator,
            archiveRefreshCoordinator,
            tagsRefreshCoordinator,
            unresolvedSavesRefreshCoordinator,
            homeRefreshCoordinator
        ]

        imageManager = ImageManager(
            imagesController: source.makeImagesController(),
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
            groupdId: Keys.shared.groupID
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
        subscriptionStore = PocketSubscriptionStore(user: user, receiptService: AppStoreReceiptService(client: v3Client))

        userManagementService = UserManagementService(appSession: appSession, user: user, notificationCenter: .default, source: source)
    }
}

extension AppSession: SessionProvider {
    public var session: Sync.Session? {
        currentSession
    }
}

extension SharedPocketKit.Session: Sync.Session { }
