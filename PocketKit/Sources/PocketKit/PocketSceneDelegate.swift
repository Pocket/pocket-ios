import UIKit


public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: RootCoordinator

    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        let events = PocketEvents()
        let sessionController = Services.shared.sessionController

        let initialState: RootViewModel.State
        if sessionController.isSignedIn {
            initialState = .main(
                MainViewModel(
                    refreshCoordinator: Services.shared.refreshCoordinator,
                    myList: MyListContainerViewModel(
                        savedItemsList: SavedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker
                        ),
                        archivedItemsList: ArchivedItemsListViewModel(
                            source: Services.shared.source,
                            tracker: Services.shared.tracker
                        )
                    ),
                    home: HomeViewModel(),
                    settings: SettingsViewModel(
                        sessionController: sessionController,
                        events: events
                    )
                )
            )
        } else {
            initialState = .signIn(
                SignInViewModel(
                    sessionController: sessionController,
                    events: events
                )
            )
        }

        self.init(
            coordinator: RootCoordinator(
                model: RootViewModel(
                    state: initialState,
                    events: events,
                    refreshCoordinator: Services.shared.refreshCoordinator,
                    sessionController: sessionController,
                    source: Services.shared.source,
                    tracker: Services.shared.tracker
                ),
                source: Services.shared.source,
                tracker: Services.shared.tracker
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
