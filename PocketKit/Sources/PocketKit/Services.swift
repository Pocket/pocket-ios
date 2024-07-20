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

@MainActor
struct Services {
    static let shared: Services = Services()

    let userDefaults: UserDefaults
    let appSession: AppSession
    let user: User
    let urlSession: URLSessionProtocol
    let source: Sync.Source
    let tracker: Tracker
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
    let subscriptionStore: SubscriptionStore
    let userManagementService: UserManagementServiceProtocol
    let lastRefresh: LastRefresh
    let lastLaunchedAppVersion: LastLaunchedAppVersion
    let featureFlagService: FeatureFlagService
    let listen: Listen
    let bannerPresenter: BannerPresenter
    let notificationCenter: NotificationCenter
    let widgetsSessionService: WidgetsSessionService
    let recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService
    let recommendationsWidgetUpdateService: RecommendationsWidgetUpdateService
    let sharedWithYouStore: SharedWithYouStore

    private let persistentContainer: PersistentContainer
    private let sceneTracker: SceneTracker

    private init() {
        guard let sharedUserDefaults = UserDefaults(suiteName: Keys.shared.groupID) else {
            fatalError("UserDefaults with suite name \(Keys.shared.groupID) must exist.")
        }
        userDefaults = sharedUserDefaults
        lastLaunchedAppVersion = UserDefaultsLastLaunchedAppVersion(defaults: userDefaults)
        lastRefresh = UserDefaultsLastRefresh(defaults: userDefaults)
        Self.handleUpgrades(lastLaunchedAppVersion: lastLaunchedAppVersion, lastRefresh: lastRefresh)
        notificationCenter = .default

        persistentContainer = .init(storage: .shared, groupID: Keys.shared.groupID)

        urlSession = URLSession.shared

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        appSession = AppSession(groupID: Keys.shared.groupID)
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            adjustSignupEventToken: Keys.shared.adjustSignUpEventToken,
            tracker: tracker,
            authenticationSessionFactory: ASWebAuthenticationSession.init
        )
        user = PocketUser(userDefaults: userDefaults)

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

        subscriptionStore = PocketSubscriptionStore(user: user, receiptService: AppStoreReceiptService(client: v3Client))

        userManagementService = UserManagementService(
            appSession: appSession,
            user: user,
            notificationCenter: notificationCenter,
            source: source
        )

        featureFlagService = FeatureFlagService(source: source, tracker: tracker, userDefaults: userDefaults, braze: braze)

        listen = Listen(
            appSession: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            networkPathMonitor: NWPathMonitor(),
            tracker: tracker,
            source: source
        )

        bannerPresenter = BannerPresenter(notificationCenter: notificationCenter)
        bannerPresenter.listen()

        recentSavesWidgetUpdateService = RecentSavesWidgetUpdateService(store: UserDefaultsItemWidgetsStore(userDefaults: userDefaults, key: .recentSavesWidget))
        recommendationsWidgetUpdateService = RecommendationsWidgetUpdateService(store: UserDefaultsItemWidgetsStore(userDefaults: userDefaults, key: .recommendationsWidget))
        widgetsSessionService = UserDefaultsWidgetSessionService(defaults: userDefaults)
        sharedWithYouStore = SharedWithYouStore(source: source, appSession: appSession)
    }

    /**
     Handle upgrades from different versions of the app.
     Currently this executes before any services are created but after we have loaded User Defaults
     // In the future this could instead send out a NSNotication that performs operations within each class themselves handling their own data.
     */
    static func handleUpgrades(lastLaunchedAppVersion: LastLaunchedAppVersion, lastRefresh: LastRefresh) {
        let lastLaunchVersion: Version? = lastLaunchedAppVersion.lastLaunch?.appVersion
        if lastLaunchVersion == nil || lastLaunchVersion! < Version("8.4.0") {
            // Reset our last sync dates if the previous app was < 8.4.0
            //    OR if lastLaunchVersion does not exist, because we used to not save it.
            // Trigger a resync of all the users data so that we download highlights data.
            // This reset needs to happen before our refresh coordinators try and download data.
            lastRefresh.reset()
        }

        // Any version after 8.4.0, if lastLaunch is empty we should not need to run ANY migrations because that means the version is below 8.4.0 or a new install/launch because we started saving the LastLaunch verison in 8.4.0
        guard lastLaunchVersion != nil else {
            // Save off the new launch version and that we finished launching.
            lastLaunchedAppVersion.launched()
            return
        }

        // Other upgrades for version numbers can go here.
        lastLaunchedAppVersion.launched()
    }

    /// Starts up all services as required.
    /// - Parameter onReset: The function to call if a service has been reset.
    /// - Note: `onReset` can be called when a migration within the persistent container fails
    func start(onReset: @escaping () -> Void) {
        if persistentContainer.didReset {
            onReset()
        }
    }
}

extension AppSession: SessionProvider {
    public var session: Sync.Session? {
        currentSession
    }
}

extension SharedPocketKit.Session: Sync.Session { }
