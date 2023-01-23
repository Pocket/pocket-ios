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
                        ),
                        savedItemsList: SavedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .saves.saves),
                            listOptions: .saved,
                            notificationCenter: .default
                        ),
                        archivedItemsList: ArchivedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .saves.archive),
                            listOptions: .archived
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
                        userDefaults: Services.shared.userDefaults,
                        notificationCenter: .default
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
                    tracker: Services.shared.tracker.childTracker(hosting: .loggedOut.screen)
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
