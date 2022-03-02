import UIKit
import AuthenticationServices
import Network


public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: RootCoordinator

    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        func mainCoordinator() -> MainCoordinator {
            MainCoordinator(
                model: MainViewModel(
                    myList: MyListContainerViewModel(
                        savedItemsList: SavedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .myList.myList)
                        ),
                        archivedItemsList: ArchivedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker.childTracker(hosting: .myList.archive)
                        )
                    ),
                    home: HomeViewModel(),
                    settings: SettingsViewModel(appSession: Services.shared.appSession)
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
}
