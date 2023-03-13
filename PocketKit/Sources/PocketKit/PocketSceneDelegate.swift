import UIKit
import AuthenticationServices
import Network
import Sync

public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: RootCoordinator

    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        func mainCoordinator() -> MainCoordinator {
            MainCoordinator(
                model: MainViewModel(
                    saves: SavesContainerViewModel(
                        searchList: SearchViewModel(
                            networkPathMonitor: NWPathMonitor(),
                            user: Services.shared.user,
                            userDefaults: Services.shared.userDefaults,
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .saves.search)
                        ) { source in
                            PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: Services.shared.tracker, source: source)
                        },
                        savedItemsList: SavedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .saves.saves),
                            viewType: .saves,
                            listOptions: .saved,
                            notificationCenter: .default
                        ),
                        archivedItemsList: SavedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .saves.archive),
                            viewType: .archive,
                            listOptions: .archived,
                            notificationCenter: .default
                        )
                    ),
                    home: HomeViewModel(
                        source: Services.shared.source,
                        tracker: Services.shared.tracker.childTracker(hosting: .home.screen),
                        networkPathMonitor: NWPathMonitor(),
                        homeRefreshCoordinator: Services.shared.homeRefreshCoordinator
                    ),
                    account: AccountViewModel(
                        appSession: Services.shared.appSession,
                        user: Services.shared.user,
                        tracker: Services.shared.tracker,
                        userDefaults: Services.shared.userDefaults,
                        userManagementService: Services.shared.userManagementService,
                        notificationCenter: .default,
                        restoreSubscription: {
                            try await Services.shared.subscriptionStore.restoreSubscription()
                        },
                        premiumUpgradeViewModelFactory: { source in
                            PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: Services.shared.tracker, source: source)
                        },
                        premiumStatusViewModelFactory: {
                            PremiumStatusViewModel(service: PocketSubscriptionInfoService(client: Services.shared.v3Client), tracker: Services.shared.tracker)
                        }
                    )
                ),
                source: Services.shared.source,
                tracker: Services.shared.tracker
            )
        }

        func loggedOutCoordinator() -> LoggedOutCoordinator {
            LoggedOutCoordinator(
                viewModel: LoggedOutViewModel(
                    authorizationClient: Services.shared.authClient,
                    appSession: Services.shared.appSession,
                    networkPathMonitor: NWPathMonitor(),
                    tracker: Services.shared.tracker.childTracker(hosting: .loggedOut.screen),
                    userManagementService: Services.shared.userManagementService
                )
            )
        }

        func rootViewModel() -> RootViewModel {
            RootViewModel(
                appSession: Services.shared.appSession,
                tracker: Services.shared.tracker,
                source: Services.shared.source,
                userDefaults: Services.shared.userDefaults
            )
        }

        self.init(
            coordinator: RootCoordinator(
                rootViewModel: rootViewModel(),
                mainCoordinatorFactory: mainCoordinator,
                loggedOutCoordinatorFactory: loggedOutCoordinator
            )
        )
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        coordinator.setup(scene: scene)
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL else {
            return
        }

        let router = Router(source: Services.shared.source)
        router.handle(url: incomingURL)
    }
}
