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
import Network

struct Services {
    static let shared: Services = { Services() }()

    let userDefaults: UserDefaults
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
    let userRefreshCoordinator: UserRefreshCoordinator
    let featureFlagsRefreshCoordinator: FeatureFlagsRefreshCoordinator
    let refreshCoordinators: [RefreshCoordinator]
    let authClient: AuthorizationClient
    let imageManager: ImageManager
    let notificationService: PushNotificationService
    let v3Client: V3ClientProtocol
    let instantSync: InstantSyncProtocol
    let braze: BrazeProtocol
    let appBadgeSetup: AppBadgeSetup
    let subscriptionStore: SubscriptionStore
    let userManagementService: UserManagementServiceProtocol
    let lastRefresh: LastRefresh
    let featureFlagService: FeatureFlagService
    let listen: Listen
    let bannerPresenter: BannerPresenter
    let notificationCenter: NotificationCenter
    let sessionBackupUtility: SessionBackupUtility
    let widgetsSessionService: WidgetsSessionService
    let recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService
    let recommendationsWidgetUpdateService: RecommendationsWidgetUpdateService
    let urlValidator: UrlValidator

    private let persistentContainer: PersistentContainer

    private init() {
        guard let sharedUserDefaults = UserDefaults(suiteName: Keys.shared.groupID) else {
            fatalError("UserDefaults with suite name \(Keys.shared.groupID) must exist.")
        }
        userDefaults = sharedUserDefaults

        notificationCenter = .default

        persistentContainer = .init(storage: .shared, groupID: Keys.shared.groupID)

        lastRefresh = UserDefaultsLastRefresh(defaults: userDefaults)
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
            appSession: appSession,
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
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        archiveRefreshCoordinator = ArchiveRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        tagsRefreshCoordinator = TagsRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source,
            lastRefresh: lastRefresh
        )

        unresolvedSavesRefreshCoordinator = UnresolvedSavesRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        homeRefreshCoordinator = HomeRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source,
            lastRefresh: lastRefresh
        )

        userRefreshCoordinator = UserRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source
        )

        featureFlagsRefreshCoordinator = FeatureFlagsRefreshCoordinator(
            notificationCenter: notificationCenter,
            taskScheduler: BGTaskScheduler.shared,
            appSession: appSession,
            source: source,
            lastRefresh: lastRefresh
        )

        refreshCoordinators = [
            savesRefreshCoordinator,
            archiveRefreshCoordinator,
            tagsRefreshCoordinator,
            unresolvedSavesRefreshCoordinator,
            homeRefreshCoordinator,
            userRefreshCoordinator,
            featureFlagsRefreshCoordinator
        ]

        imageManager = ImageManager(
            imagesController: source.makeImagesController(),
            imageRetriever: KingfisherManager.shared,
            source: source,
            cdnURLBuilder: CDNURLBuilder()
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

        userManagementService = UserManagementService(
            appSession: appSession,
            user: user,
            notificationCenter: notificationCenter,
            source: source
        )

        featureFlagService = FeatureFlagService(source: source, tracker: tracker, userDefaults: userDefaults)

        listen = Listen(
            appSession: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            networkPathMonitor: NWPathMonitor(),
            tracker: tracker,
            source: source
        )

        bannerPresenter = BannerPresenter(notificationCenter: notificationCenter)
        bannerPresenter.listen()

        sessionBackupUtility = SessionBackupUtility(
            userDefaults: userDefaults,
            store: PocketEncryptedStore(),
            notificationCenter: notificationCenter
        )

        recentSavesWidgetUpdateService = RecentSavesWidgetUpdateService(store: UserDefaultsItemWidgetsStore(userDefaults: userDefaults, key: .recentSavesWidget))
        recommendationsWidgetUpdateService = RecommendationsWidgetUpdateService(store: UserDefaultsItemWidgetsStore(userDefaults: userDefaults, key: .recommendationsWidget))
        widgetsSessionService = UserDefaultsWidgetSessionService(defaults: userDefaults)
        urlValidator = UrlValidator()
    }
}

extension AppSession: SessionProvider {
    public var session: Sync.Session? {
        currentSession
    }
}

extension SharedPocketKit.Session: Sync.Session { }
