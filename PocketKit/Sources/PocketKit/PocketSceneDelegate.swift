import UIKit


public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: RootCoordinator

    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        let events = PocketEvents()
        let session = Services.shared.session
        let tokenStore = Services.shared.accessTokenStore

        let initialState: RootViewModel.State
        if session.userID != nil, session.guid != nil, tokenStore.accessToken != nil {
            initialState = .main(MainViewModel(
                refreshCoordinator: Services.shared.refreshCoordinator
            ))
        } else {
            initialState = .signIn(
                SignInViewModel(
                    authClient: Services.shared.authClient,
                    session: session,
                    accessTokenStore: tokenStore,
                    tracker: Services.shared.tracker,
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
                    authClient: Services.shared.authClient,
                    session: session,
                    accessTokenStore: tokenStore,
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
